import torch
import torch.nn.functional as F
from torch.utils.data import DataLoader, TensorDataset
from tqdm import tqdm
import numpy as np
import os
import clip
import torchvision.transforms as T

from models.decoder import NovelImageDecoder


class EmbeddingDecoderTrainer:
    def __init__(self, device, lr=1e-4):
        self.device = device

        # Load frozen CLIP vision encoder
        self.clip_model, _ = clip.load("ViT-B/32", device=device)
        for p in self.clip_model.parameters():
            p.requires_grad = False  # freeze CLIP

        # Our decoder (trainable)
        self.decoder = NovelImageDecoder().to(device)

        self.optimizer = torch.optim.Adam(self.decoder.parameters(), lr=lr)

        # Blur operator for structural loss
        self.blur = T.GaussianBlur(5, sigma=1.0)

    def train_step(self, emb):
        emb = emb.to(self.device)

        # Normalize + scale embeddings
        emb = emb / emb.norm(dim=1, keepdim=True)
        emb = emb * 3.0

        # Add slight noise to prevent collapse
        emb = emb + torch.randn_like(emb) * 0.05

        # ---- Decode to image ----
        decoded = self.decoder(emb)

        # ---- CLIP cosine loss ----
        decoded_224 = torch.nn.functional.interpolate(decoded, (224, 224))
        img_clip = self.clip_model.encode_image(decoded_224)
        img_clip = img_clip / img_clip.norm(dim=1, keepdim=True)

        L_clip = 1 - torch.cosine_similarity(img_clip, emb, dim=1).mean()

        # ---- Total Variation Loss (smooth image) ----
        L_tv = (
            torch.mean(torch.abs(decoded[:, :, :, :-1] - decoded[:, :, :, 1:])) +
            torch.mean(torch.abs(decoded[:, :, :-1, :] - decoded[:, :, 1:, :]))
        )

        # ---- Structural Consistency Loss ----
        blurred = self.blur(decoded)
        L_struct = torch.mean((decoded - blurred) ** 2)

        # ---- Final Loss ----
        loss = L_clip + 0.2 * L_tv + 0.3 * L_struct

        self.optimizer.zero_grad()
        loss.backward()
        self.optimizer.step()

        return loss.item()

    def train(self, embeddings, epochs=150, batch_size=4):
        dataloader = DataLoader(TensorDataset(embeddings), batch_size=batch_size, shuffle=True)

        print("\n📌 Training Decoder...\n")
        for epoch in range(epochs):
            pbar = tqdm(dataloader, desc=f"Epoch {epoch+1}/{epochs}")
            for batch in pbar:
                loss = self.train_step(batch[0])
                pbar.set_postfix({"loss": f"{loss:.4f}"})

        # Save trained model
        os.makedirs("trained_models", exist_ok=True)
        torch.save(self.decoder.state_dict(), "trained_models/novel_decoder.pth")
        print("\n[✓] Training complete — saved to: trained_models/novel_decoder.pth")


def main():
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"[INFO] Using device: {device}")

    # ---- Load saved EEG → CLIP embeddings ----
    path = "generated_images/eeg_embeddings.npy"
    if not os.path.exists(path):
        raise FileNotFoundError(f"❌ Missing file: {path}. Run infer.py first to generate embeddings.")

    embeddings = torch.tensor(np.load(path), dtype=torch.float32)
    print(f"[✓] Loaded embeddings: shape={embeddings.shape}")

    trainer = EmbeddingDecoderTrainer(device)
    trainer.train(embeddings, epochs=150)


if __name__ == "__main__":
    main()
