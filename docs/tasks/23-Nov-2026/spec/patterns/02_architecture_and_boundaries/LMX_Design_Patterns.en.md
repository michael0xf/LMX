# LMX: Architecture and component boundaries

Java represents explicit interfaces, classes, and modular server development; Go represents function composition and compact service contracts. The pair tests whether the pattern needs class hierarchies or only equivalent boundaries and effects.

All eleven original entries remain. Layered, Hexagonal, Clean, and Onion overlap in techniques but emphasize different dependency directions. Message owns mutable state. Microservices, EDA, and Strangler use the documented HTTP and Message transports; their listings expose cores and precise ports rather than claiming complete infrastructure.

## Files

- [Markdown](LMX_Comparison_02_architecture_and_boundaries.md)
- [Excel](LMX_Comparison_02_architecture_and_boundaries.xlsx)
- [PDF](LMX_Comparison_02_architecture_and_boundaries.pdf)
- [CSV](LMX_Comparison_02_architecture_and_boundaries.csv)

## Catalog

### 005. [Layered Architecture](005_layered_architecture_comparision.md)

Presentation calls the application layer, which calls the data layer.

**Scenario:** Compute the cost of three units priced at 10 through three explicit layers.

**Observation:** 30.

The application intentionally depends on concrete data, unlike dependency inversion in the following three patterns.

### 006. [Hexagonal Architecture (Ports and Adapters)](006_hexagonal_architecture_comparision.md)

The application core receives external dependencies through ports.

**Scenario:** Use one core to price two units with adapters returning 10 and 12.

**Observation:** 20 + 24 = 44; replacing the adapter does not change the core.

The port is ()→int and is called once in every language. A function is sufficient; a separate adapter class is optional.

### 007. [Clean Architecture](007_clean_architecture_comparision.md)

Domain policy and the use case are separated from the outer presentation.

**Scenario:** For income 100 and expense 60, the policy requires at least 30 remaining; an outer presenter maps the decision to 200.

**Observation:** 200; income 70 and expense 60 produce 422.

The key is dependency direction toward policy/use cases. The single-file example shows links; project modules enforce the boundary.

### 008. [Onion Architecture](008_onion_architecture_comparision.md)

A domain entity is central; application behavior uses an outer persistence port.

**Scenario:** Save Order(quantity=3, price=10) through an injected repository and obtain its domain total.

**Observation:** 30; the repository retains the supplied order object.

This highlights Onion’s entity-centered arrangement. It overlaps with Hexagonal/Clean but remains a separate original entry.

### 009. [Microservices](009_microservices_comparision.md)

Services have independent deployment boundaries and communicate through a transport contract.

**Scenario:** Checkout asks Catalog for three units through an endpoint and route; the fixture returns 30.

**Observation:** One request to https://catalog.example/quote with quantity=3; the successful semantic reply contains 30.

LMX already has an HTTP transport profile. Java/Go Exchange is the same excluded adapter. A common external fixture supplies quantity=3, checks endpoint/route, and invokes catalog; this checks the business boundary, not network deployment.

### 010. [Event-Driven Architecture](010_event_driven_architecture_comparision.md)

A publisher reports a fact and independent subscribers process the event.

**Scenario:** Deliver an event carrying quantity=3 to Audit and Stock as two Message deliveries.

**Observation:** Each address receives one event carrying 3; one handler’s completion does not imply the other’s completion.

Explicit recipients make the example deterministic; a subscription catalog can live in a router Message. Java/Go Delivery must provide equivalent separate delivery lanes.

### 013. [Pipe and Filter](013_pipe_and_filter_comparision.md)

Independent transformations are connected in an ordered data flow.

**Separate implementation comparison:** [093. Pipe — generic implementation](093_pipe_implementation_comparision.md)

**Scenario:** For one item -3, normalize its sign, double it, then add 1.

**Observation:** 7; intermediate values are 3 and 6.

LMX uses its direct generic core composition, Java its real andThen method, and Go ordinary calls. Implementation093 is a separate implementation comparison, not a dependency of the foreign usage examples.

### 093. [Pipe — generic implementation](093_pipe_implementation_comparision.md)

Implement generic ordered function composition without an int-only adapter.

**Usage examples:** [013. Pipe and Filter](013_pipe_and_filter_comparision.md)

**Scenario:** Compose A→B and B→C to A→C, evaluate first then second exactly once, and relay failures without executing the second stage after first-stage failure.

**Observation:** The int fixture returns7; a heterogeneous string→length→Boolean fixture also works; a failure in the first stage skips the second.

All three implementations retain callable references and explicitly compose ordinary calls. LMX preserves its exact source input policy and declared failure set through the shared adapter mechanism. Java and Go use static generic parameters.

### 014. [Blackboard](014_blackboard_comparision.md)

Independent knowledge sources read a common board and contribute applicable facts.

**Scenario:** The board starts with raw=4. Expert A derives normalized=5, expert B derives result=10. The scheduler tries B before A.

**Observation:** 10; another pass is required after normalized is added.

The B→A order distinguishes this from a fixed filter chain. Knowledge sources test applicability; the controller repeats until no change.

### 015. [Microkernel / Plug-in](015_microkernel_comparision.md)

A stable core provides an extension point with replaceable implementation.

**Scenario:** Install an x*2 plugin and run 5; then install x*3 and repeat without changing the core.

**Observation:** 10 + 15 = 25.

This compares one minimal extension point. A multi-name registry and discovery are unnecessary for this single point; every implementation has replaceable behavior.

### 046. [Anti-Corruption Layer (ACL)](046_anti_corruption_layer_comparision.md)

A translation boundary preserves domain meaning when accessing another system.

**Scenario:** Legacy returns a price of 12 whole dollars; the new domain expects cents. For quantity=2 obtain 2400.

**Observation:** 2400; 12 becomes 1200 exactly at the ACL boundary.

The ACL translates semantics, not just method names. Moving Legacy behind HTTP does not remove that responsibility; the transport adapter remains separate.

### 047. [Strangler Fig](047_strangler_fig_comparision.md)

A router progressively moves selected capabilities to a new implementation.

**Scenario:** Route 1 initially uses legacy and then new; route 2 remains on legacy.

**Observation:** Responses 101, 201, 102; demo returns their sum, 404.

One capability switches independently of the rest. Enabling it does not imply fallback after the new service has already produced effects.
