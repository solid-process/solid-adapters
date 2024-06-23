## `Solid::Adapters` Examples

> **Attention:** Each example has its own **README** with more details.

1. [Ports and Adapters](./ports_and_adapters) - Implements the Ports and Adapters pattern. It uses **`Solid::Adapters::Interface`** to provide an interface from the application's core to other layers.

2. [Anti-Corruption Layer](./anti_corruption_layer) - Implements the Anti-Corruption Layer pattern. It uses the **`Solid::Adapters::Proxy`** to define an interface for a set of adapters, which will translate an external interface (`vendors`) to the application's core interface.
