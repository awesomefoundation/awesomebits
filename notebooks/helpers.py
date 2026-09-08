"""Shared helpers for Signal Score notebooks."""

import os
import re
from pathlib import Path

import duckdb
import matplotlib.pyplot as plt
import seaborn as sns

# --- Data source ---
DEFAULT_DB_PATH = os.path.join(
    os.path.dirname(__file__), "..", ".scratch", "data", "awesomebits.duckdb"
)
DB_PATH = os.environ.get("AWESOMEBITS_DB", DEFAULT_DB_PATH)


def connect(read_only: bool = True) -> duckdb.DuckDBPyConnection:
    """Open the DuckDB database."""
    path = str(Path(DB_PATH).resolve())
    return duckdb.connect(path, read_only=read_only)


# --- Plotting defaults ---
def setup_plotting():
    """Configure consistent plot styling."""
    sns.set_theme(style="whitegrid", palette="muted", font_scale=1.1)
    plt.rcParams.update(
        {
            "figure.figsize": (10, 6),
            "figure.dpi": 100,
            "axes.titlesize": 14,
            "axes.labelsize": 12,
        }
    )


# --- Text helpers ---
TEXT_FIELDS = ["about_me", "about_project", "use_for_money"]


def combined_text(row) -> str:
    """Combine the three text fields into one string."""
    parts = [str(row.get(f, "") or "") for f in TEXT_FIELDS]
    return " ".join(p.strip() for p in parts if p.strip())


def word_count(text: str) -> int:
    """Count words in text."""
    return len(text.split()) if text.strip() else 0


# --- Money extraction ---
# Currency symbols and written forms
CURRENCY_SYMBOLS = r"[\$\£\€\¥\₹\₩\₫\₱\₺\₽\฿\₿]"
CURRENCY_PREFIXED = r"(?:A|NZ|CA|HK|S|US|C)\$"
CURRENCY_CODES = (
    r"\b(?:USD|GBP|EUR|AUD|NZD|CAD|CHF|JPY|CNY|INR|BRL|MXN|ZAR|SEK|NOK|DKK|"
    r"KRW|SGD|HKD|TWD|THB|MYR|PHP|IDR|VND|CZK|PLN|HUF|RON|BGN|HRK|RUB|TRY|"
    r"ILS|AED|SAR|QAR|KWD|BHD|OMR|CLP|COP|PEN|ARS|UYU)\b"
)
CURRENCY_WORDS = (
    r"\b(?:dollars?|pounds?|euros?|yen|yuan|rupees?|rand|krona|kronor|"
    r"francs?|pesos?|reais?|real|won|baht|ringgit|dong|crowns?|zloty|forints?|"
    r"lira|shekels?|dirhams?|riyals?)\b"
)

# Number patterns (handles 1,000 and 1.000 and 1 000)
NUMBER_PATTERN = r"\d[\d,.\s]*\d|\d+"

# Combined money pattern
MONEY_PATTERN = re.compile(
    rf"(?:"
    rf"(?:{CURRENCY_PREFIXED}|{CURRENCY_SYMBOLS})\s*(?:{NUMBER_PATTERN})"  # symbol before number
    rf"|(?:{NUMBER_PATTERN})\s*(?:{CURRENCY_PREFIXED}|{CURRENCY_SYMBOLS})"  # number before symbol
    rf"|(?:{NUMBER_PATTERN})\s*(?:{CURRENCY_WORDS})"  # number + written currency
    rf"|(?:{CURRENCY_CODES})\s*(?:{NUMBER_PATTERN})"  # ISO code + number
    rf"|(?:{NUMBER_PATTERN})\s*(?:{CURRENCY_CODES})"  # number + ISO code
    rf")",
    re.IGNORECASE,
)


def extract_money_mentions(text: str) -> list[str]:
    """Extract money/currency mentions from free text."""
    return MONEY_PATTERN.findall(text)


def money_mention_count(text: str) -> int:
    """Count money mentions in text."""
    return len(extract_money_mentions(text))


# --- Label helpers ---
def label_project(row) -> str:
    """Assign a label based on funded_on / hidden_at."""
    import pandas as pd

    if pd.notna(row.get("funded_on")):
        return "funded"
    if pd.notna(row.get("hidden_at")):
        return "hidden"
    return "unlabeled"


# --- Chapter helpers ---
ENGLISH_SPEAKING_COUNTRIES = {
    "United States",
    "Canada",
    "Australia",
    "United Kingdom",
    "Ireland",
    "New Zealand",
    "Worldwide",
}
