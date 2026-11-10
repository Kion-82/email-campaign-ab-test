"""Download the Hillstrom email campaign dataset into data/raw/."""

from pathlib import Path
import urllib.request

DATA_URL = (
    "http://www.minethatdata.com/"
    "Kevin_Hillstrom_MineThatData_E-MailAnalytics_DataMiningChallenge_2008.03.20.csv"
)

# Resolve paths relative to the project root, not the current working directory
PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_PATH = PROJECT_ROOT / "data" / "raw" / "hillstrom.csv"


def download(url: str = DATA_URL, dest: Path = RAW_PATH, overwrite: bool = False) -> Path:
    """Download the raw CSV file. Skip the download if the file already exists."""
    dest.parent.mkdir(parents=True, exist_ok=True)

    if dest.exists() and not overwrite:
        print(f"File already exists, skipping download: {dest}")
        return dest

    print(f"Downloading from {url} ...")
    urllib.request.urlretrieve(url, dest)
    print(f"Saved to {dest} ({dest.stat().st_size / 1e6:.1f} MB)")
    return dest


if __name__ == "__main__":
    download()
    