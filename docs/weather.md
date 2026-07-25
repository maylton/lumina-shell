# Weather settings

Lumina exposes weather configuration under **Settings → Weather**.

## Visibility

The **Show weather** switch controls both presentation and background activity.
When it is disabled, the Dashboard weather block is hidden and Lumina stops
location and forecast requests.

## Location modes

### Automatic by IP

Automatic mode requests approximate city, region, latitude, and longitude for
the current public network address. Lumina does not save the IP address. It
stores only the resolved city, region, coordinates, and cache timestamp under
the Quickshell cache directory.

The cached automatic location is valid for 24 hours and is used when the
location provider is temporarily unavailable. Selecting **Refresh** forces a
new automatic lookup. VPNs, proxies, mobile networks, and corporate gateways
may report a nearby city or the location of their public exit node.

### Manual city

Manual mode sends the configured place name to the Open-Meteo geocoding API.
The setting accepts a city or another recognizable place name. The resulting
coordinates remain runtime state and the typed place name is stored in the
feature-scoped weather preferences file.

`LUMINA_WEATHER_LOCATION` remains available as a development override and
takes precedence over the graphical preference for that shell process.

## Refresh interval

The page supports 15, 30, 60, and 120 minute forecast intervals. **Refresh**
updates the forecast immediately and, in automatic mode, also renews the
GeoIP location.

## Persistence

Weather location mode, manual city, and refresh interval are stored at:

```text
Quickshell.stateDir/lumina-weather.json
```

The runtime resolves `Quickshell.stateDir` according to the active shell
configuration and XDG environment. The automatic-location cache is stored
separately under `Quickshell.cacheDir` so it can expire or be removed without
changing the user's preference.

Runtime state is available through:

```bash
qs ipc -p /path/to/lumina-shell call weather status
qs ipc -p /path/to/lumina-shell call weather refresh
```
