# Holiday data inputs

`api/holidays/*.json` is the reviewed country dataset and the payload served by
GitHub Pages. The synchronization tool treats years listed in
`overrides.json.curatedYears` as authoritative and never replaces them with
calculated data.

For non-curated years, `tool/sync_holidays.py` calculates public holidays with
the MIT-licensed `python-holidays` package. The default horizon is the previous
year, current year, and two following years. Existing historical curated years
remain available.

`overrides.json` supports three reviewable corrections:

- `textReplacements`: normalization applied to names and descriptions.
- `removals`: records removed by country, date, and name.
- `upserts`: complete canonical holiday records added or replaced. Every
  upsert includes an official `source.url` and `source.verifiedOn` date.

`data/curated-drift.json` is generated alongside the hosted and bundled data.
It reports baseline holiday dates that are absent from authoritative curated
years. An empty `gaps` array means every calculated date is either present or
explicitly reviewed through an override.

The tool validates every record, rewrites payload counts and
`api/countries.json`, and generates the bundled Dart map. Never edit the
generated Dart file directly.
