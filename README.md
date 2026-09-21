# DataverseNL Metadata Dashboard 📊

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
<!-- TODO: this fork doesn't have its own archived release yet; add a DOI badge here once one exists. -->

This dashboard asseses metadata attributes of Utrecht University DataverseNL datasets against common publishing criteria.

✨ [Access the DataverseNL Metadata Compliance Dashboard](https://utrechtuniversity.github.io/dataverse-compliance-dashboard/) ✨

![Dashboard screen recording](assets/dashboard.gif)

## Publishing Criteria Assesed ✅

1. Prescence of a CC-BY licence for non restricted data.
   For the current implementation, this is assessed by checking that the dataset has a non-empty licence other than CC0-1.0.
2. Custom terms for restricted data
3. Dataset contact is present.
   Because the crawler export does not expose dataset contact emails, and UU's dataset contacts are almost entirely individual researcher names rather than a shared institutional label this requirement is assessed     simply as: at least one named dataset contact is present in the dataset contact metadata.
4. At least one author has an ORCID.
5. Description is present.
6. Keywords are present.

Currently the assesment criteria is based on [Masstricht's Dataverse operational Guidelines](https://documents.library.maastrichtuniversity.nl/S/759ea4c8-1b80-4e41-8636-731cea321382), a new version will eventually be deployed to align the criteria with [Utrecht University's own Publishing Guidelines](https://zenodo.org/records/15149066).

## Data source and architecture 🧩

- The browser app does not query Dataverse live. It reads the latest normalized dashboard import prepared by the background metadata workflow.   
- The metadata import is gathered from the [DataverseNL instance](https://dataverse.nl/dataverse/UU) using [scholarsportal/dataverse-metadata-crawler](https://github.com/scholarsportal/dataverse-metadata-crawler).  
- The crawler exports can be placed in the local, git-ignored `data/raw/` directory, and the transformation scripts in `scripts/` convert that output into dashboard-ready JSON for the dashboard import.

The workflow is kept separate:

```text
Dataverse API / crawler export
        ↓
raw metadata in data/raw/
        ↓
scripts/transform_crawler_output.py
        ↓
normalized data/datasets.json
        ↓
static dashboard on GitHub Pages
```

## Running locally 🚀

Clone the repository and serve it as a small static site:

```bash
git clone https://github.com/UtrechtUniversity/dataverse-compliance-dashboard.git
cd dataverse-compliance-dashboard
python -m http.server 8000
```

Then open `http://localhost:8000`.  
**Note:** If you run it from `localhost` or `127.0.0.1`, the app falls back to `data/datasets.json` for local development.

## Citation 📚

If you use this software in research, please cite the repository metadata in [CITATION.cff](https://github.com/UtrechtUniversity/dataverse-compliance-dashboard/blob/main/CITATION.cff).  

> Hernandez Serrano, P., & Westerbeek, E. (2026). DataverseNL Metadata Compliance Dashboard (v26.05). <!-- TODO: add a DOI here once this fork has its own archived release -->

## Acknowledgements 🙌

Eventhough there are great clients for metadata extraction, we found a very neat one [scholarsportal/dataverse-metadata-crawler](https://github.com/scholarsportal/dataverse-metadata-crawler), maintained by [Scholars Portal](https://github.com/scholarsportal), a service of the Ontario Council of University Libraries, and developed by [Ken Lui](https://github.com/kenlhlui) 👍🏼.  

[DataverseNL](https://dataverse.nl/) is a consortium service supported by [DANS](https://dans.knaw.nl/en/about/). This dashboard is derived from the dashboard independently developped by Maastricht University Library.

## Maintenance

Original author: [Pedro V Hernandez Serrano](https://github.com/pedrohserrano)  
Maintainer (UU fork): [Emily Westerbeek](https://github.com/EmilyWes)  
Contact UU Dataverse: info.rdm@uu.nl
Released under [MIT License](LICENSE)
