# TODO
## Multi - intersect joints
- Ability to accept general input requirements to a junction something like:
```
{
  "connections": [
    {
      "unitvec": [-x,y,z],
      "angle": 0,
      "id": 10,
      "od": 12
    },
    {
      "unitvec": [-x,y,-z],
      "angle": 90,
      "id": 8,
      "od": 10
    }
  ]
}
```
## Common HVAC Connectors and Fittings

### Done

- **Press-Fit Fittings:** They compress a gasket between the fitting and pipe. 3D printed versions need to ensure the right balance between tightness and not damaging the gasket.

### Not Done

- **Compression Fittings:** These join two pipes or a pipe to a fixture using a nut and ferrule for a seal. Need to consider material strength for 3D printing to ensure they can handle the pressure without deforming.

- **Flare Fittings:** Designed for high-pressure applications with a flared pipe end sealed by a nut. The 3D printed version must have precise angles and smooth surfaces to ensure a proper seal.

- **Sweat Fittings:** Copper fittings soldered to the pipe. For 3D printing, look into creating a mock-soldered appearance for ease of identification, although actual soldering won't be applicable.

- **Threaded Fittings:** These have male or female threads and require a sealant. Try to design to be sealant-less and consider that threads must be accurately printed to ensure they are leak-proof and compatible with standard pipes.

- **Crimp Fittings:** Used with PEX piping and require a crimp ring. Ensure the 3D printed part can withstand the crimping force without cracking.

- **Push-Fit Fittings:** Allow for easy connection and disconnection without tools. The internal gripping mechanism must be designed to secure the pipe firmly in 3D printed versions.

- **Barbed Fittings:** For use with flexible tubing, secured with a clamp. The barb must be designed to prevent pipe damage in 3D printed versions.

- **Quick Disconnect Fittings:** Designed for easy disconnection and reconnection. The 3D printed design should focus on ease of use while maintaining a secure connection.

- **Ball Valves and Gate Valves:** Used for controlling flow and must match the pipe size and type. The 3D printed design should ensure smooth operation and proper sealing.

- **Rotolock Valves:** Threaded valves for compressor connections. The 3D printed threads need to be precise and may require post-processing for smoothness.

- **Union Fittings:** Designed for easy removal, they must be accurately printed to ensure easy disassembly and a good seal when connected.

- **Capillary Tubes:** Not a fitting but a refrigerant flow control component that connects to fittings. For 3D printing, focus on the internal diameter precision.

- **Schraeder Valves:** Used for refrigerant charging. The 3D printed version must ensure that the valve core fits securely and is leak-proof.

### General Considerations for 3D Printed HVAC Connectors:

- **Material Selection:** Must be durable, able to withstand the temperatures and pressures of refrigerant gases, and resistant to chemical degradation.

- **Dimensional Accuracy:** Essential for ensuring that fittings are leak-proof and compatible with existing pipes and components.

- **Structural Integrity:** The connectors must be able to withstand mechanical stresses without failing.

- **Compatibility with Seals and Gaskets:** Surfaces should be smooth to not damage any seals or gaskets they come into contact with.

- **Regulatory Compliance:** Must meet industry standards for safety and performance.

- **Post-Processing:** Some printed parts may require additional processing, such as threading or smoothing, to ensure proper function.

- **Testing:** Prototypes should be rigorously tested for pressure and leaks before being implemented in actual systems.
