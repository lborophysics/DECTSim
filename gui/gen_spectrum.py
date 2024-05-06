import spekpy as sp

s = sp.Spek(kvp=80,th=12,dk=0.1) # Generate a spectrum (80 kV, 12 degree tube angle)

s.export_spectrum('80kvp.spk') # Export the spectrum to a file

s = sp.Spek(kvp=40,th=12,dk=0.1) # Generate a spectrum (80 kV, 12 degree tube angle)

s.export_spectrum('40kvp.spk') # Export the spectrum to a file

s = sp.Spek(kvp=120,th=12,dk=0.1) # Generate a spectrum (120 kV, 12 degree tube angle)

s.export_spectrum('120kvp.spk') # Export the spectrum to a file
