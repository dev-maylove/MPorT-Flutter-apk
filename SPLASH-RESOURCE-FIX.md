# Splash Resource Fix

Fixed Android resource linking failure in `launch_background.xml`.

## Root cause
`android:drawable` accepts a drawable/resource reference, not a raw color literal such as `#06080F`.

## Fix
Added `@color/splash_background` in `res/values/colors.xml` and changed the layer-list to reference it. Launch/normal theme background references were also normalized to the same resource.

This preserves the MPorT dark splash appearance while allowing Android AAPT resource linking to succeed.
