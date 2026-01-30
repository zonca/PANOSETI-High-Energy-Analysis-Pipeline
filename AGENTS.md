# AGENTS.md - Guide for Working with PANOSETI High Energy Analysis Pipeline

This document provides essential information for AI agents working with the PANOSETI-High-Energy-Analysis-Pipeline repository.

## Project Overview

PANOSETI-High-Energy-Analysis-Pipeline contains tools for analyzing images of air showers captured by PANOSETI (Panoramic Optical SETI) telescopes. The project is a multi-component data pipeline that processes raw telescope data through to scientific analysis.

## Repository Structure

```
PANOSETI-High-Energy-Analysis-Pipeline/
├── simulation-tools/        # CORSIKA air shower simulation setup
├── analysis-tools/          # Data analysis notebooks and processed data
├── eventbuilding/           # Raw data processing (pcap to ROOT conversion)
├── install_corsika/         # CORSIKA 7.7550 installation and compilation
├── misc-tools/              # Utility scripts for telescope coordination
└── *.C                     # ROOT macros for visualization and processing
```

## Project Dependencies

### Core Dependencies
- **ROOT**: Data analysis framework
  - Version: Verified v6.28/04 (v6.22 and v6.30.06 also work)
  - Required for: Data processing, visualization, .C macros, ROOT file I/O
  - Get via: `root-config --cflags --glibs` for compilation flags

- **CORSIKA 7**: Cosmic Ray Simulations for KAascade
  - Version: 7.7550 (in `install_corsika/` directory) or 7.7410
  - Compilation requirements:
    - Models: QGSJET-II-04 (high energy), URQMD 1.3.1 (low energy)
    - Options: IACT, CHERENKOV, VOLUMEDET, SLANT, ATMEXT
  - Configuration utility: `coconut`

- **corsikaIOreader**: Read CORSIKA binary output files
  - Version: https://github.com/nkorzoun/corsikaIOreader
  - Installation: `make corsikaIOreader`
  - Usage: `corsikaIOreader -cors <input> -histo <output> -abs CORSIKA`

### Additional Dependencies
- **Python packages**: pandas, numpy, matplotlib, astropy, seaborn
- **C++ libraries**: libpcap (for pcap reading), g++ compiler
- **GNU Parallel**: For batch job processing

## Essential Commands

### CORSIKA Installation

**PANOSETI configuration (recommended - all required options):**
```bash
cd install_corsika
./download_corsika.sh    # Download CORSIKA 7.7550
./install_corsika_panoseti.sh  # Compile with QGSJET-II-04, URQMD, IACT, CHERENKOV, ATMEXT, VOLUMEDET
```

**Basic installation (fewer options):**
```bash
cd install_corsika
./download_corsika.sh    # Download CORSIKA 7.7550
./install_corsika.sh     # Compile with basic configuration (QGSJET-II-04, URQMD, CHERENKOV, LPM)
```

**Manual configuration:**
```bash
cd install_corsika/corsika-77550
./coconut                  # Interactive configuration
./coconut --expert         # Expert mode with more options
./coconut --expert --no-cache # Disable caching
```

**Clean and rebuild:**
```bash
cd install_corsika/corsika-77550
make distclean             # Clean build artifacts
# Then run coconut configuration again
```

### CORSIKA Simulation

**Run single simulation:**
```bash
cd install_corsika/corsika-77550/run
./corsika77550Linux_QGSII_urqmd < input-file.inp > output.log
```

**Test run:**
```bash
cd install_corsika/corsika-77550/run
./corsika77550Linux_QGSII_urqmd < all-inputs > test-output.log
```

**Batch simulation (simulation-tools directory):**
```bash
# Edit corsika.sh to set RUNDIR, IODIR, OUTDIR
./corsika.sh <input-file> <run-id>
```

**Run batch with parallel processing:**
```bash
# Edit runbatch.sh to set paths
./runbatch.sh  # Runs 16 jobs in parallel
```

### Data Processing (Event Building)

**Compile pcapreader:**
```bash
cd eventbuilding
source make_pcapreader.sh
# Or manually:
g++ -Wall -o pcapreader pcapreader.cpp -lpcap `root-config --cflags --glibs`
```

**Convert pcap data to ROOT format:**
```bash
pcapreader <pcap-file>
# Generates: <pcap-file>.root
```

**Standard event building workflow (from eventbuilding/README):**
```bash
# 1. Clean rate spikes
root -q
> .L clean_ratespikes.C
> clean_ratespikes("file.pcapng.root", 25);

# 2. Merge quabos into telescope events
root -q
> .L makeevents.C
> makeevents_timehistomatch("cleaned/file.root", <telescope_id>);
# Example telescope IDs: 12, 760, 1016

# 3. Calculate pedestals and variances
root -q
> gROOT->LoadMacro("processcamevents.C");
> calcPedestals("cleaned/file.root.T12");

# 4. Build array events
root -q
> gROOT->LoadMacro("makearrayevents.C");
> makearrayevents("cleaned/file.root");
```

### ROOT Macro Execution

```bash
# Run ROOT macros interactively
root -q panodisplay.C
root -q macro.C\(arg1, arg2\)

# In ROOT REPL
root
> .L macro.C
> function_name(arg1, arg2)
> .q
```

### Analysis Notebooks

```bash
cd analysis-tools
jupyter notebook analysis.ipynb
jupyter notebook energyregression.ipynb
jupyter notebook qfactor.ipynb
```

## Code Conventions and Patterns

### C++ Code
- **Compilation**: Always include `root-config --cflags --glibs` for ROOT projects
- **Headers**: Include both C++ (`<iostream>`, `<string>`) and ROOT headers
- **ROOT integration**: Load macros with `gROOT->LoadMacro("macro.C")` before using functions
- **Command line parsing**: Standard `argc`, `argv` approach

### Shell Scripts
- Use `#! /usr/bin/env bash` shebang
- Set working directories with absolute paths or relative to script location
- Use environment variables for configurable paths (RUNDIR, IODIR, OUTDIR)
- Parallel processing with GNU Parallel: `parallel --verbose --jobs N command ::: file-list`

### CORSIKA Input Files (.inp)
- Format: Fortran-style data cards with keywords and values
- Common cards:
  - `RUNNR <number>`: Run number
  - `NSHOW <number>`: Number of showers to simulate
  - `PRMPAR <number>`: Primary particle type (1=gamma, 14=proton)
  - `ERANGE <Emin> <Emax>`: Energy range in GeV
  - `THETAP <min> <max>`: Zenith angle range in degrees
  - `TELFIL <filename>`: Telescope configuration file
  - `EXIT`: End of input
- Example config file in: `simulation-tools/example/example.inp`

### ROOT File Structure
- Event building usually outputs `.root` files with naming: `<input>.root.T<id>` for telescope-specific data
- Completed array events: `<input>.root.array`
- Simulation outputs typically in same directory as input with `.root` extension

### Python Notebooks
- Sequential markdown cells explaining sections (Imports, Read Data, Analysis)
- DataFrames named with numeric suffixes (df1=gamma, df2=cosmic-ray)
- Use astropy for astronomical coordinates and WCS transformations

## File Naming Conventions

### CORSIKA Output Files
- `DAT<runnr>`: Particle data file
- `CER<runnr>`: Cherenkov photon data
- `TEC<runnr>`: Telescope configuration
- `TLU<runnr>`: Longitudinal profile
- `T000<runnr>`: Additional telescope data

### Telescope-Specific Files
- Telescope IDs: T12, T760, T1016 (common IDs in the pipeline)
- Naming: `<filename>.root.T<id>` for processed telescope data

### PANOSETI Data Files
- Raw: `.pcapng` format (network packet captures)
- Converted: `.pcapng.root` after pcapreader
- Cleaned: `<filename>.root.cleaned` after rate spike removal
- Array events: `<filename>.root.array` after event building

## Important Gotchas

### CORSIKA Installation
- **EPoS vs QGSJET**: Version 7.8 removed QGSJET-II-04 in favor of QGSJETIII-01. PANOSETI requires QGSJET-II-04, so use version 7.7550.
- **COCONUT interactive mode**: When running coconut manually, provide input selections sequentially (2, 5, 4, 1, 2, 1, 3, 7, 9, z, y, f) for standard PANOSETI configuration.
- **Compiler warnings**: Non-critical warnings appear during build (deprecated `ftime()`, SURPRISING arrays). These can be ignored.
- **Missing dependencies**: Warnings about `root-config` and `BOOST_PROGRAM_OPTIONS` are expected and non-fatal.

### Data Processing
- **Parameter corrections**: The `misc-tools/param.sh` script contains date-specific telescope pointing corrections that must be checked before processing new data.
- **Time matching**: When building telescope events with `makeevents_timehistomatch`, the histogram time parameter must match the histogram in use.
- **Pedestal calculation**: Must run pedestal calculation before array event building.
- **File cleanup**: Always remove old CORSIKA output files (`rm -f DAT* CER* TEC* TLU* T000*`) before new runs.

### ROOT Version Compatibility
- **v6.22 issue**: Must remove `-lfreetype` from root-config library list. Use full manual command with all individual libraries instead.
- **Compilation flags**: For ROOT v6.30.06 (tested working): `g++ -Wall -o pcapreader pcapreader.cpp -lpcap $(root-config --cflags --glibs)`

### Path Handling
- CORSIKA scripts assume specific directory structure (run/ containing executable and input files)
- Always ensure data directories exist before running batch scripts
- Use absolute paths in shell scripts to avoid path confusion

### Jupyter Notebooks
- Cell execution count (e.g., `execution_count: 633`) indicates cells were previously run
- Test data in `analysis-tools/testdata/` may not be present in repository

## Testing

### Verify CORSIKA Installation
```bash
cd install_corsika/corsika-77550/run
./corsika77550Linux_QGSII_urqmd < /dev/null 2>&1 | grep -E "INTERFACE FOR|CHERENKOV|VOLUME|EXTERNAL|QGSJET|URQMD"
# Should show:
# - QGSJET-II MODEL ACCORDING TO S.S. OSTAPCHENKO
# - URQMD-MODEL FROM THE URQMD-COLLABORATION
# - ZENITH ANGLE DEPENDENCE FOR VOLUME DETECTOR
# - INTERFACE FOR EXTERNAL ATMOSPHERIC PROFILES ENABLED
# - CHERENKOV RADIATION IS GENERATED
# - INTERFACE FOR SYSTEMS OF TELESCOPES OR OTHER CHERENKOV DETECTORS ENABLED

# Test run
./corsika77550Linux_QGSII_urqmd < all-inputs > test.log
# Check for successful completion and output files
ls -l DAT* CER* TEC* TLU*
```

### Test Event Building
Use example files in `simulation-tools/example/`:
- `example.inp`: CORSIKA input
- `example.telescope`: Telescope configuration
- `example.root`: Sample processed output

### Verify ROOT Installation
```bash
root-config --version
root-config --cflags --glibs  # Should output without errors
```

## Common Workflows

### 1. New Simulation Run
```bash
cd install_corsika/corsika-77550/run
# Create input file based on simulation-tools/example/example.inp
./corsika77550Linux_QGSII_urqmd < my-config.inp > my-output.log
# Check DAT*, CER*, etc. files generated
```

### 2. Process Real Data
```bash
cd eventbuilding
./make_pcapreader.sh
pcapreader raw_data.pcapng
# Then follow event building workflow from README
```

### 3. Analyze Processed Data
```bash
cd analysis-tools
jupyter notebook analysis.ipynb
# Load ROOT files in notebook for analysis
```

## Documentation References

- **CORSIKA**: `install_corsika/corsika-77550/doc/CORSIKA_GUIDE7.7550.pdf`
- **CORSIKA Website**: https://www.iap.kit.edu/corsika/
- **CORSIKA Contact**: Dr. Tanguy Pierog, tanguy.pierog@kit.edu
- **corsikaIOreader**: https://github.com/nkorzoun/corsikaIOreader
- **PANOSETI Project**: https://panoseti.ucsd.edu/
- **Project Wiki**: https://github.com/nkorzoun/PANOSETI-High-Energy-Analysis-Pipeline/wiki

## Version Notes

- CORSIKA 7.7550 supports QGSJET-II-04 (required for PANOSETI)
- CORSIKA 7.8 uses QGSJETIII-01 instead (not PANOSETI-compatible)
- COCONUT version 3.1 included with CORSIKA 7.7550
- URQMD 1.3.1 is the required low-energy hadronic model (version 1.3cr is the compatible compiled version)

## Additional Resources in Repository

- `datapipeline.drawio.png`: Visual representation of the data pipeline
- `panodisplay_REALDATA.C`: ROOT macro for displaying real telescope data
- `panodisplay.C`: ROOT macro for displaying simulated data (in simulation-tools/)
- Various ROOT macros in eventbuilding/ for data processing steps
- Corner case handling in simulation-tools/panodisplay.C (lookup tables for pixel integration)