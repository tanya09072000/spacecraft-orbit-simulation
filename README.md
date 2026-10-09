# Orbital Simulation

A MATLAB application for numerical simulation of spacecraft motion in
Earth orbit, including selected perturbation models and visibility
analysis for ground stations.

## Features

-   Numerical integration of the equations of motion using `ode113`.
-   Central Earth gravity.
-   Earth oblateness perturbation (`J2`).
-   Atmospheric drag, including the effect of Earth's rotation.
-   Solar radiation pressure (SRP) and Earth shadowing.
-   Third-body gravitational perturbations from the Sun and Moon.
-   Calculation of orbital elements and ascending-node passages.
-   Visibility analysis for configured ground stations.
-   Plotting and simulation summary generation.

## Requirements

-   MATLAB with support for `ode113`, `datetime`, and
    `griddedInterpolant`.
-   **SPICE MICE for MATLAB** for calculations involving the Sun, Moon,
    or SRP.
-   The SPICE ephemeris file `de440.bsp`. It is not included in the
    repository and must be obtained separately from an official NAIF
    source.
-   Python available from the command line as `python` for the NRLMSISE
    atmosphere interface.

For calculations using SPICE, make sure MICE is on the MATLAB path and
that `de440.bsp` is located in `Ephemerides/kernels/`. The project also
expects the `naif0012.tls` leap-seconds kernel.

For NRLMSISE, MATLAB launches `nrl_query.py` as a separate Python
process. Verify that `python` is available in the environment used by
MATLAB.

## Getting Started

1.  Clone or download the repository.
2.  Install and configure the required dependencies.
3.  Open the project root directory in MATLAB.
4.  Run:

``` matlab
main
```

`main.m` adds the project folders to the MATLAB path, loads settings
from `config/inputData.m`, validates the input data, runs the
simulation, creates plots, and prints a summary.

## Configuring a Simulation

The main input parameters are defined in `config/inputData.m`.

### Scenario

The `Scenario` structure contains the simulation epoch and duration,
stop time, time system, and coordinate-frame settings.

### Spacecraft

The `Spacecraft` structure includes:

-   `mass` --- spacecraft mass in kg;
-   `area` --- reference area in m²;
-   `Cr` --- reflectivity coefficient used by the SRP model.

### Initial Orbit

`InitialState.mode` selects how the initial state is specified:

-   `"OrbitalElements"` --- orbital elements are provided in `Orbit`;
-   `"StateVector"` --- position and velocity are provided in
    `InitialState.position` and `InitialState.velocity`.

For the orbital-elements mode, `a` is the semi-major axis in km, `e` is
eccentricity, and `i`, `raan`, `argPerigee`, and `trueAnomaly` are
angles in degrees.

### Perturbation Models

The models can be enabled or disabled in the `Model` structure:

``` matlab
Model.J2   = true;
Model.drag = true;
Model.SRP  = true;
Model.sun  = true;
Model.moon = true;
```

Enable only models for which the required dependencies and input data
are available.

### Atmosphere and Aerodynamics

-   `Environment.model` selects the atmospheric model.
-   `Environment.updateStep` sets the atmosphere update interval.
-   `Aerodynamics.model` selects the aerodynamic drag-coefficient model.

The current code includes the `Legacy` aerodynamic model. `Sentman1961`
and `SchaafChambre` are listed in the code but are not implemented and
will fail if selected. The `Exponential` atmosphere option is also
incomplete.

The NRLMSISE model uses space-weather data from a CSV file under
`Environment/DragCoefficient/atmosphere/common/`.

## Project Structure

  -----------------------------------------------------------------------
  Path                                Purpose
  ----------------------------------- -----------------------------------
  `main.m`                            Main entry point

  `runSimulation.m`                   Coordinates the simulation workflow

  `config/`                           Input scenario and model settings

  `constants/`                        Physical constants

  `dynamics/`                         Equations of motion and
                                      perturbation models

  `orbit/`                            State conversions and
                                      orbital-element calculations

  `Environment/`                      Atmospheric models, aerodynamics,
                                      and shadow calculations

  `Ephemerides/`                      Ephemeris utilities and SPICE
                                      kernels

  `groundStation/`                    Ground-station elevation and
                                      visibility calculations

  `visualization/`                    Plots and ascending-node processing

  `results/`                          Simulation summary generation

  `tests/`                            Existing tests

  `validation/`                       Input-data validation
  -----------------------------------------------------------------------

## Outputs

Depending on the enabled models, the program can produce:

-   spacecraft trajectory and state history;
-   orbital-element history;
-   visibility intervals for configured ground stations;
-   atmospheric data for visualization when drag is enabled;
-   a simulation summary.

The results are collected in the `Results` structure returned by
`runSimulation`.

## Comparison with STK

The MATLAB results were compared with STK using ascending-node times,
orbital elements at a reference epoch, and a visibility interval for the
Norilsk ground station.

### Ascending-node times

Times are reported in UTCG.

  Event                         STK            MATLAB           Difference (MATLAB − STK)
  ----------------------------- -------------- -------------- ---------------------------
  Ascending node, 19 Sep 2026   06:12:36.709   06:12:36.710                      +0.001 s
  Ascending node, 23 Sep 2026   03:03:48.619   03:03:48.793                      +0.174 s

### Orbital elements on 23 Sep 2026

  Parameter                          STK        MATLAB   Difference (MATLAB − STK)
  --------------------- ---------------- ------------- ---------------------------
  Semi-major axis         6872.390292 km   6872.391 km                +0.000708 km
  Eccentricity                  0.001345      0.001340                   −0.000005
  Inclination                    97.466°      97.4556°                    −0.0104°
  RAAN                            3.936°       3.9349°                    −0.0011°
  Argument of perigee           351.013°     351.1398°                    +0.1268°
  True anomaly                    8.987°       8.8602°                    −0.1268°

The STK report displays some values with fewer decimal places than the
MATLAB output. Differences for these parameters should therefore be
interpreted with the rounding of the source report in mind.

### Norilsk ground-station visibility interval

Times are reported in UTCG.

  ------------------------------------------------------------------------
  Parameter        STK              MATLAB            Difference (MATLAB −
                                                                      STK)
  ---------------- ---------------- ---------------- ---------------------
  AOS / start of   19 Sep 2026      19 Sep 2026                   +1.951 s
  visibility       05:04:33.979     05:04:35.930     

  LOS / end of     19 Sep 2026      19 Sep 2026                   +6.619 s
  visibility       05:09:42.282     05:09:48.901     

  Duration         308.303 s        312.971 s                     +4.668 s
  ------------------------------------------------------------------------

### Interpretation

In this comparison, ascending-node times agree within 0.174 s, and the
reported semi-major axes differ by approximately 0.7 m. Differences
remain in inclination and argument of perigee. The Norilsk visibility
duration differs by 4.668 s.

This comparison is a useful reference case, but it does not by itself
demonstrate full equivalence between the MATLAB and STK models. A
reproducible validation requires matching initial conditions, epoch,
coordinate frames, time systems, perturbation models, and
station-visibility criteria. Full-precision STK values should also be
retained to distinguish physical differences from report rounding.

## Important Notes

-   Check the settings in `config/inputData.m` and verify that all
    required dependencies and data files are available before running a
    simulation.
-   SPICE MICE and `de440.bsp` are required when using the Sun, Moon, or
    SRP models.
-   Atmospheric drag requires a working Python/NRLMSISE interface or
    another supported and correctly configured atmosphere model.
-   The existence of files in `tests/` does not mean that the complete
    physical model has been fully validated. High-confidence use
    requires comparison with an independent reference solution and an
    assessment of numerical accuracy.

## Third-Party Components and Licensing

The project includes third-party Python NRLMSISE-00 code. Before
redistributing the project, review its license and preserve any required
attribution. Follow the distribution terms for SPICE MICE and NAIF
ephemeris kernels as well. Add a license for this project if you intend
to publish it for reuse.
