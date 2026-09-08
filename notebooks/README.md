# Signal Score Notebooks

Jupyter notebooks for analyzing the Awesome Foundation Signal Score pipeline.

## Setup

```bash
pip install -r notebooks/requirements.txt
```

## Data

Notebooks read from a DuckDB database. Default path: `.scratch/data/awesomebits.duckdb`

Override with an environment variable:

```bash
export AWESOMEBITS_DB=/path/to/your/awesomebits.duckdb
```

To build the database from CSV exports, run:

```bash
ruby scripts/signal-score/import_data.rb
```

## Notebooks

| Notebook | Description |
|----------|-------------|
| `01_eda.ipynb` | Corpus stats, chapter distributions, label rates, text analysis |
| `02_feature_engineering.ipynb` | Pre-scorer features, TF-IDF, money extraction, feature correlations |
| `03_model_evaluation.ipynb` | Batch results, model comparison, test-retest reliability, cross-chapter |

## No Real Data

These notebooks are git-tracked. They contain no real grant application text.
All analysis reads from a local DuckDB database that lives in `.scratch/` (gitignored).
