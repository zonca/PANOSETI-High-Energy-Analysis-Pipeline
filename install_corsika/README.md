# CORSIKA Installation for PANOSETI

CORSIKA 7.7550 (released April 30, 2024) - compiled for the PANOSETI High Energy Analysis Pipeline.

## Build for PANOSETI

```bash
./download_corsika.sh          # Download if not already present
./install_corsika_panoseti.sh  # Compile with PANOSETI options
```

## Configuration

- **Hadronic models**: QGSJET-II-04 (high energy) + URQMD 1.3cr (low energy)
- **Physics options**: IACT (telescope detector), CHERENKOV, ATMEXT (external atmosphere), VOLUMEDET

## Running CORSIKA

```bash
cd corsika-77550/run
./corsika77550Linux_QGSII_urqmd < input-file.inp > output.log
```

## Output Files

- `DAT<runnr>` - Particle data
- `CER<runnr>` - Cherenkov photon data
- `TEC<runnr>` - Telescope configuration
- `TLU<runnr>` - Longitudinal profile

## Data Files Required

Located in `corsika-77550/run/`:
- `qgsdat-II-04`, `sectnu-II-04` - QGSJET cross-sections
- `UrQMD-1.3.1-xs.dat` - URQMD cross-sections
- `atmabs.dat`, `mirreff.dat`, `quanteff.dat` - Atmosphere and detector data

## Clean old runs

```bash
rm -f DAT* CER* TEC* TLU* T000*
```