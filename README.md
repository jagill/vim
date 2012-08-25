# JAG's vim files

These are my personal vim files -- feel free to use for inspiration or whatever else.

One additional thing of interest is in `bin/update_plugins.py` and
`config/plugins.yml`, which I use to manage my vim plugins (using Pathogen, of
course).  They are declared in `plugins.yml`, and the `update_plugins.py`
script controls installing, deleting, and updating them. 

**IMPORTANT**: You must run `bin/update_plugins.py` before launching vim for the first time.
Run `bin/update_plugins.py --help` for more info.
