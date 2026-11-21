# LMX: Objects, dependencies, and composition

Java shows nominal interfaces, classes, and explicit object contracts; Python shows dynamic composition and functions. The comparison avoids forcing Java hierarchies on every language and reveals actual nominal/structural differences.

All ten original patterns remain. Examples use one serial owner; LMX shared mutable state belongs to a Message. Marker Interface and Fluent Interface explicitly distinguish equivalent observations from identical nominal typing or chaining syntax.

## Files

- [Markdown](LMX_Comparison_08_objects_and_composition.md)
- [Excel](LMX_Comparison_08_objects_and_composition.xlsx)
- [PDF](LMX_Comparison_08_objects_and_composition.pdf)
- [CSV](LMX_Comparison_08_objects_and_composition.csv)
- [Methodology](../COMPARISON_METHODOLOGY.en.md)
- [All 90 patterns](../PATTERN_CATALOG_90.en.md)
- [Validation status](../VALIDATION.md)
- [Message and existing HTTP transport profile](../MESSAGE_HTTP_PROFILE.md)

## Catalog

### 072. [Dependency Injection](072_dependency_injection_comparision.md)

The composition root supplies a ready dependency to the client.

**Scenario:** One client reads and doubles values from two supplied sources returning 5 and 7.

**Observation:** 10 + 14 = 24.

LMX uses call injection; Java/Python use constructor injection. The source contract is the same: ()→int with no additional effects.

### 073. [Service Locator](073_service_locator_comparision.md)

The client retrieves a service from an explicitly chosen registry.

**Scenario:** Resolve key 1 to a source returning 42; unknown keys use a fallback returning 0.

**Observation:** 42.

Unlike DI, the client requests the concrete service within its own logic. Every version uses one fixed key and a defined fallback.

### 074. [Null Object](074_null_object_comparision.md)

A neutral implementation satisfies the same contract so the client needs no null check.

**Scenario:** Run work with value=10 and logging disabled by a neutral implementation.

**Observation:** 10; the logger is called once and changes no state.

A neutral callable is sufficient for a one-operation contract. This is a functional Null Object without a mandatory wrapper class.

### 075. [Object Pool](075_object_pool_comparision.md)

A pool lends a resource and accepts it back for reuse.

**Scenario:** A capacity-one pool: acquire, refuse a second acquisition, return the first, and acquire the same reference.

**Observation:** 1 means first=again and busy=null.

All versions show identity reuse, occupancy, and return. LMX arena collection does not replace release of a foreign resource.

### 076. [Simple Factory](076_simple_factory_comparision.md)

One function selects and creates a concrete product from an input discriminator.

**Scenario:** Create products of kinds 0 and 1 with costs 5 and 9.

**Observation:** Sum 14; each call creates a separate product.

Product selection is encapsulated in a function. This is Simple Factory, without a virtual factory method or Abstract Factory family.

### 077. [Multiton](077_multiton_comparision.md)

One owner provides one stable instance per key.

**Scenario:** For fixed keys 0 and 1, two reads of key 0 share a write of value=7; key 1 remains 0.

**Observation:** 70.

Unlike Flyweight, these objects are mutable and keyed, not automatically interned by content.

### 078. [Marker Interface](078_marker_interface_comparision.md)

A separate marker admits an object without adding behavioral methods.

**Scenario:** Check a marked and an unmarked object; encode accepted*10 + rejected.

**Observation:** 10.

Java and Python check nominal membership. LMX checks an explicit structure that another author can reproduce. The positive scenario matches, but nominal guarantees differ.

### 079. [Fluent Interface](079_fluent_interface_comparision.md)

API operations return a context so the interaction can continue fluently.

**Scenario:** Set count=3 and price=7 through the returned same context, then obtain their product.

**Observation:** 21; both setters return the original object.

Java/Python show literal dot chaining; LMX uses the same return-context contract with ordinary method paths. This is an API analogue, not a claim of identical chaining syntax.

### 080. [Type Object](080_type_object_comparision.md)

An object’s kind is described by ordinary data shared by instances.

**Scenario:** Two objects reference one TypeData with damage=2. Change damage to 3; the second object sees the new value.

**Observation:** 23: the first read is 2 and the second is 3.

Shared properties become data in all three languages. LMX graph inspection/composition can help load such descriptions, but this example needs no loader.

### 081. [Extension Object](081_extension_object_comparision.md)

An object exposes a separate extension with additional behavior and access to its state.

**Scenario:** Attach a Report extension to Host(value=7), query it, and obtain twice the value, 14.

**Observation:** 14; Host identity is preserved.

A separate object provides the additional interface. This differs from replacing Host or assigning a method a new lexical owner.

## Boundaries

Sizes are computed from each pattern’s three listings. They exclude implementations of supplied libraries, runtime, HTTP hosts and databases. Read each case’s individual limits. IDs retain the original list; 86–90 are explicit additions.
