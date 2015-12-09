# tronsister32-framework
Game development framework for the Tronsister-32 ISA

##Usage:
`./build_game.sh <game_folder> <flags>`

Optional: `-f` includes tronsistor32 framework code in assembly

Game folders should follow form of:
```
game_folder/
    main.asm
    build/
    assets/
        color_palette.csv
        font/
            main.ttf
        foreground/
            *.png
        background/
            *.png
```

##Requirements:
- Python 2.7
- pip (https://pip.pypa.io/en/stable/installing/)
- virtualenv (https://virtualenv.readthedocs.org/en/latest/)

**IMPORTANT:** You must create a virtualenv called 'venv' in the root of this project or it will not build succesfully.