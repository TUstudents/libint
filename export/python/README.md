# Libint2 Python Bindings

Python bindings for the Libint library - a high-performance library for computing molecular integrals in quantum chemistry.

## Installation

```bash
pip install libint2
```

## Usage

```python
import libint2

# Create an engine for overlap integrals
engine = libint2.Engine(libint2.Operator.overlap, 2, 0)

# Get configuration information
config = libint2.configuration_accessor()
print(f"Libint2 version: {libint2.__version__}")
print(f"Configuration: {config}")
```

## Features

This build includes support for:
- Electron repulsion integrals (ERI)
- G12 integrals (for explicitly-correlated methods like MP2-F12)
- Gradient calculations
- Various basis sets

## Documentation

For full documentation, see: https://github.com/evaleev/libint

## License

LGPL-3.0-or-later
