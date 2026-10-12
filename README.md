# Orbital Simulation

A MATLAB application for numerical simulation of spacecraft motion in Earth orbit. It supports selected perturbation models, atmospheric drag, orbital-element analysis, ascending-node processing, and ground-station visibility analysis.

The example scenario is a low Earth orbit with an altitude of approximately 494 km and an inclination of approximately 97.5°, propagated for four days after separation. Two ground stations are configured locally; their identities and coordinates are not published in this repository.

> **Reproducibility note:** The project requires local configuration and external dependencies that are not all included in this repository. Follow the setup steps below before running the simulation.

## Features

- Numerical integration using MATLAB `ode113` in an inertial frame.
- Central Earth gravity and the J2 oblateness perturbation.
- Atmospheric drag, including atmospheric co-rotation with Earth, when enabled.
- NRLMSISE-00 atmosphere through a Python interface and CIRA-72 atmosphere support.
- Space-weather inputs such as F10.7, Ap, and Kp from project CSV data.
- Solar radiation pressure (SRP) with a cylindrical Earth shadow.
- Third-body gravity from the Sun and Moon using SPICE ephemerides.
- Orbital elements, ascending-node passages, and local time of ascending node (LTAN) processing.
- Ground-station elevation and visibility intervals.
- Plots and simulation-summary generation.
- Optional MATLAB App Designer GUI: `OrbitalSimulationApp.mlapp`.

## Requirements

### MATLAB

- MATLAB with support for `ode113`, `datetime`, and `griddedInterpolant`.
- Aerospace Toolbox for functions used by the project, including `dcmeci2ecef` and `juliandate`.
- SPICE MICE for MATLAB when running configurations that use SPICE-based Sun, Moon, or SRP calculations.

The exact minimum MATLAB release has not been specified or verified. Use a MATLAB release that supports the functions used by the project.

### Python

- Python 3 available from the command line as `python` for the NRLMSISE-00 interface.
- The Python executable visible to MATLAB must be the intended interpreter.

The repository's Python interface is launched as a separate process. This README does not claim that every operating-system or Python version combination has been tested.

### External SPICE data

- `de440.bsp` is not included in this repository and must be obtained separately from an official NAIF source.
- `naif0012.tls` is used as the leap-seconds kernel. Verify that it is present in `Ephemerides/kernels/`.
- MICE is not included in the repository. Install it separately and add its MATLAB files to the MATLAB path.

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/tanya09072000/spacecraft-orbit-simulation.git
cd spacecraft-orbit-simulation
```

Alternatively, download the repository as a ZIP file from GitHub and extract it.

### 2. Prepare external dependencies

1. Install MATLAB and the required Aerospace Toolbox functions.
2. Install SPICE MICE if the selected force models use SPICE.
3. Obtain `de440.bsp` from an official NAIF source and place it in `Ephemerides/kernels/`.
4. Check that `naif0012.tls` exists in `Ephemerides/kernels/`.
5. If atmospheric drag uses NRLMSISE-00, verify that Python 3 is callable as `python` from the environment used by MATLAB.

Some configurations may not require every dependency. For example, SPICE dependencies are needed for the calculations that use SPICE-based Sun, Moon, or SRP data.

### 3. Configure ground stations locally

The public repository intentionally does not include the private ground-station configuration file.

The current configuration expects:

```text
config/privateStations.m
```

Create this file locally. It must define a MATLAB function named `privateStations` that returns the `Station` structure expected by `config/inputData.m`. Each station should provide the fields used by the project:

| Field | Meaning | Unit |
|---|---|---|
| `name` | Station label | — |
| `lat` | Geodetic latitude | degrees |
| `lon` | Longitude, east positive | degrees |
| `alt` | Altitude above the ellipsoid | km |
| `minElevation` | Minimum elevation for visibility | degrees |

Use the station coordinates you are authorized to use. Do not commit `config/privateStations.m` if it contains confidential coordinates. The file should remain excluded by `.gitignore`.

If you do not have the station configuration, the current setup may stop with an error rather than run with placeholder coordinates.

### 4. Verify files and dependencies

In MATLAB, change the current folder to the repository root. Check that the required configuration, data, and external files are present before running.

From a Windows Command Prompt, you can check Python with:

```bash
python --version
```

In MATLAB, inspect installed products with:

```matlab
ver
```

Make sure the Aerospace Toolbox is listed if your chosen code path requires it. Also confirm that MICE is on the MATLAB path and that the required SPICE kernels are in the expected location for SPICE-dependent runs.

### 5. Run the simulation

From the repository root in MATLAB, run:

```matlab
main
```

The main workflow adds project folders to the MATLAB path, loads the input settings, validates the input data, runs the simulation, creates plots, and prints a summary.

The workflow can also be invoked step by step:

```matlab
Data = inputData();
validateInputData(Data);
Results = runSimulation(Data);
```

Run the step-by-step commands only after the project folders are available on the MATLAB path. If these functions are not found, start with `main.m` from the repository root or add the project folders as the project expects.

## Configuration

The main configuration is defined in `config/inputData.m`. Units generally use kilometres for distances, kilometres per second for velocities, and degrees for angles unless a field or function documents otherwise.

### Scenario and initial orbit

The `Scenario` structure defines launch and separation times, simulation duration, stop time, time system, and frame settings.

`InitialState.mode` selects the initial-state representation:

- `"OrbitalElements"` uses the elements in `Orbit`.
- `"StateVector"` uses `InitialState.position` and `InitialState.velocity`.

For orbital-elements mode, `a` is the semi-major axis in km, `e` is eccentricity, and `i`, `raan`, `argPerigee`, and `trueAnomaly` are angles in degrees.

`Orbit.LTAN` is informational only in the current implementation. The initial RAAN is taken from `Orbit.raan`; it is not automatically derived from LTAN. Keep the values consistent manually when required.

### Spacecraft

- `mass`: spacecraft mass in kg.
- `area`: reference area in m².
- `Cr`: reflectivity coefficient used by the SRP model.

### Perturbation models

The force models are enabled or disabled in the `Model` structure. The example configuration below enables atmospheric drag:

```matlab
Model.J2   = true;
Model.drag = true;
Model.SRP  = true;
Model.sun  = true;
Model.moon = true;
```

These are example settings. The actual settings used for a run are those in your local `config/inputData.m`. Only enable models when their dependencies and input data are available.

### Atmosphere and aerodynamics

- `Environment.model` selects the atmospheric model.
- `Environment.updateStep` sets the atmosphere update interval.
- `Aerodynamics.model` selects the aerodynamic drag-coefficient model.

The current code includes the `Legacy` aerodynamic model. `Sentman1961` and `SchaafChambre` are listed in the code but are not implemented and will fail if selected. The `Exponential` atmosphere option is incomplete.

The NRLMSISE and CIRA models use space-weather data from a CSV file under `Environment/DragCoefficient/atmosphere/common/`. If requested dates are missing, the implementation may interpolate values between available dates. Interpolated values are approximations and should not be treated as observations.

### Ground stations

Each `Station` structure defines a ground station using `name`, `lat`, `lon`, `alt`, and `minElevation`. Longitude is east-positive; altitude is in kilometres.

## Project Structure

```text
.
├── main.m                      Main entry point
├── runSimulation.m             Coordinates the simulation workflow
├── OrbitalSimulationApp.mlapp  Graphical interface
├── config/                     Input scenario and model settings
├── constants/                  Physical constants
├── validation/                 Input-data validation
├── dynamics/                   Equations of motion and perturbations
├── orbit/                      State conversions, elements, LTAN
├── Environment/                Atmospheric models, aerodynamics, shadow
├── Ephemerides/                Ephemeris utilities and SPICE kernels
├── groundStation/              Elevation and visibility calculations
├── visualization/              Plots and ascending-node processing
├── results/                    Simulation summary generation
├── tests/                      Existing tests
└── validation/                 Validation cases and utilities
```

## Models

- **J2:** standard perturbing acceleration in the inertial frame.
- **Atmospheric drag:**  
  `a_drag = -0.5 * Cx * A / m * rho * |v_rel| * v_rel`, where  
  `v_rel = v - omega x r` accounts for atmospheric co-rotation with Earth.
- **Solar radiation pressure:** uses the inverse-square distance dependence, reflectivity coefficient, area-to-mass ratio, and a cylindrical Earth-shadow model.
- **Third-body gravity:** uses geocentric positions of the Sun and Moon from SPICE.

## Outputs

Depending on the enabled models and execution path, the `Results` structure returned by `runSimulation` can contain:

| Field | Content |
|---|---|
| `Trajectory` | Time [s] and state `[x y z vx vy vz]` [km, km/s] |
| `Visibility` | Per-station elevation, visibility sessions, and first contact |
| `Orbit` | Orbital-element history |
| `AscendingNode` | Elements, altitude, and LTAN at ascending nodes |
| `Summary` | Key simulation results |
| `Atmosphere` | Atmospheric data when available and drag is enabled |
| `Data` | Input data used for the run |
| `Constants` | Physical constants |

## Comparison with STK

The MATLAB results have been compared with STK using ascending-node times, orbital elements at a reference epoch, and a visibility interval for one reference ground station. The station's identity and coordinates are not published in this README.

### Ascending-node times

Times are reported in UTCG.

| Event | STK | MATLAB | Difference (MATLAB − STK) |
|---|---:|---:|---:|
| Ascending node, 19 Sep 2026 | 06:12:36.709 | 06:12:36.710 | +0.001 s |
| Ascending node, 23 Sep 2026 | 03:03:48.619 | 03:03:48.793 | +0.174 s |

### Orbital elements on 23 Sep 2026

| Parameter | STK | MATLAB | Difference (MATLAB − STK) |
|---|---:|---:|---:|
| Semi-major axis | 6872.390292 km | 6872.391 km | +0.000708 km |
| Eccentricity | 0.001345 | 0.001340 | −0.000005 |
| Inclination | 97.466° | 97.4556° | −0.0104° |
| RAAN | 3.936° | 3.9349° | −0.0011° |
| Argument of perigee | 351.013° | 351.1398° | +0.1268° |
| True anomaly | 8.987° | 8.8602° | −0.1268° |

The STK report displays some values with fewer decimal places than the MATLAB output. Differences should be interpreted with the rounding of the source report in mind.

The argument of perigee and true anomaly differ by equal and opposite amounts: their sum, the argument of latitude, is 360.000° in both solutions. For a nearly circular orbit (`e ≈ 0.00135`), the perigee direction is poorly defined, so this difference does not by itself indicate a position error.

### Reference ground-station visibility interval

Times are reported in UTCG.

| Parameter | STK | MATLAB | Difference (MATLAB − STK) |
|---|---|---|---:|
| AOS / start of visibility | 19 Sep 2026 05:04:33.979 | 19 Sep 2026 05:04:35.930 | +1.951 s |
| LOS / end of visibility | 19 Sep 2026 05:09:42.282 | 19 Sep 2026 05:09:48.901 | +6.619 s |
| Duration | 308.303 s | 312.971 s | +4.668 s |

### Interpretation

For this reference run, ascending-node times agree within 0.174 s and the reported semi-major axes differ by approximately 0.7 m. Differences remain in inclination and argument of perigee. The reference station's visibility duration differs by 4.668 s.

This is a reference comparison, not proof of full equivalence between the MATLAB and STK models. Reproducible validation requires matching initial conditions, epoch, coordinate frames, time systems, force models, integrator settings, and station-visibility criteria. Full-precision STK values should be retained to distinguish physical differences from report rounding.

## Troubleshooting

### `privateStations.m` is missing

Create `config/privateStations.m` locally. It must define `privateStations()` and return the required `Station` structure. Do not commit confidential station coordinates.

### Python or NRLMSISE cannot be started

1. Run `python --version` in the operating-system terminal.
2. Confirm that the same Python executable is visible to MATLAB.
3. Check that the NRLMSISE Python script and required input data are present in the expected project folders.
4. Read the full MATLAB error message to identify the failed path or process.

### SPICE kernel or MICE errors

1. Confirm that MICE is installed and on the MATLAB path.
2. Confirm that `de440.bsp` is located in `Ephemerides/kernels/`.
3. Confirm that `naif0012.tls` is present in the same expected kernel directory.
4. Check that the selected model configuration actually requires SPICE.

### Missing space-weather dates

The atmosphere interface may interpolate between available records. Check the warning and the source CSV to understand which dates were used. Interpolated values can affect atmospheric density and therefore drag.

### Functions are not found

Run MATLAB from the repository root and start with `main.m`, which is intended to set up the project path. If a function is still missing, verify that its file is present in the repository and that no required external folder has been omitted.

### Results differ from STK

Check that the initial state, epoch, frames, time system, force models, atmospheric settings, integrator tolerances, and ground-station visibility criteria match. The known simplifications below can also contribute to differences.

## Known Limitations

- The atmosphere is evaluated for one point (latitude, longitude, and time) per `Environment.updateStep` and held constant over that interval; density variations along the orbit are therefore not fully modelled.
- The altitude used for density lookup is measured from a sphere of radius `Re`, whereas the atmosphere model is defined in geodetic altitude.
- The Earth-shadow model is cylindrical and does not include penumbra.
- Station visibility uses simplified Earth rotation (GMST only, without precession and nutation) and a geocentric local vertical. This can contribute to AOS/LOS differences with STK.
- The `Legacy` aerodynamic coefficient model depends on a wall-temperature polynomial whose validity range should be reviewed.
- The integration step is limited to 1 s in the described configuration, which can increase run time.

## Important Notes

- Check `config/inputData.m` and verify that required dependencies, local configuration, and data files are available before running.
- SPICE MICE and the required kernels are needed when using SPICE-based Sun, Moon, or SRP calculations.
- Atmospheric drag requires a working Python/NRLMSISE interface or another supported and correctly configured atmosphere model.
- The presence of files in `tests/` does not mean that the complete physical model has been fully validated. High-confidence use requires comparison with an independent reference solution and an assessment of numerical accuracy.
- The setup steps in this README have not been independently tested from a clean machine. Verify them in a fresh clone before treating the project as fully reproducible.

## Third-Party Components and Licensing

The project uses third-party Python NRLMSISE-00 code. Before redistributing it, verify the applicable license and preserve any required attribution. Check the distribution terms for SPICE MICE and NAIF kernels as well. No license for this project is specified here; add an appropriate `LICENSE` file if you intend to permit reuse.
