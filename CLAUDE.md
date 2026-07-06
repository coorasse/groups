# Groups

Gestione delle prenotazioni di gruppi per eventi (parte gestionale + form pubblica di prenotazione).

## Test

- La test suite è scritta con **RSpec** e deve rimanere completa: ogni nuova funzionalità o bugfix va accompagnata dai relativi test.
- **SimpleCov** è configurato in `spec/rails_helper.rb` con una soglia minima di **line coverage al 100%**: la suite fallisce se la copertura scende sotto il 100%. Non abbassare la soglia; se del codice non è copribile, va rimosso o testato, non escluso.

## Responsive / Mobile

Questa app viene utilizzata **sia su desktop che su mobile**: l'esperienza mobile è importante quanto quella desktop.

- Ogni modifica alla UI va pensata e verificata **anche a viewport mobile** (~375px), non solo su desktop.
- Preferire layout responsive (Bulma columns/flex, unità relative); evitare elementi a larghezza fissa che sforano su schermi stretti.
- Verificare che i controlli restino raggiungibili su mobile (es. la navbar collassa sotto i 1024px dietro il burger: ciò che deve essere sempre disponibile va tenuto fuori dal menu collassabile).
- Quando si testa nella preview, controllare il rendering sia a larghezza desktop sia mobile.
