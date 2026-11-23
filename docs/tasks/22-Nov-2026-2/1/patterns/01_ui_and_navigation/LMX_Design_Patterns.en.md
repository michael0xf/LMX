# LMX: Presentation and navigation

TypeScript represents browser-oriented functions and objects; C# represents explicit contracts and .NET property notifications. Both permit toolkit-independent UI examples.

The seven original entries remain distinct. MVC, MVP, MVVM, and Redux differ in state propagation; Front, Page, and Application Controllers differ in responsibility. HTTP examples use the existing LMX transport profile and compare the receiving core rather than a full web host.

## Files

- [Markdown](LMX_Comparison_01_ui_and_navigation.md)
- [Excel](LMX_Comparison_01_ui_and_navigation.xlsx)
- [PDF](LMX_Comparison_01_ui_and_navigation.pdf)
- [CSV](LMX_Comparison_01_ui_and_navigation.csv)
- [Methodology](../COMPARISON_METHODOLOGY.en.md)
- [All 90 patterns](../PATTERN_CATALOG_90.en.md)
- [Validation status](../VALIDATION.md)
- [Message and existing HTTP transport profile](../MESSAGE_HTTP_PROFILE.md)
- [Operands and libraries: edition rules](../OPERAND_USAGE_PROFILE.md)
- [Review of all 90 examples](../OPERAND_LIBRARY_REVIEW.md)

## Catalog

### 001. [MVC (Model-View-Controller)](001_mvc_comparision.md)

The model owns state, the controller handles input, and the view reads the model.

**Scenario:** Increment a counter from 5 to 6 and read it through a separate view.

**Observation:** 6; the controller never writes a displayed-value field.

All variants preserve the three roles. LMX stores model references in DATA; the controls use instance fields.

### 002. [MVP (Model-View-Presenter)](002_mvp_comparision.md)

A passive view receives the final display value from its presenter.

**Scenario:** Add 2 to a model initially holding 5; the presenter explicitly updates a passive screen.

**Observation:** Model 7, screen 7; demo returns 77.

Unlike the MVC example, the screen never reads the model. Its view contract can be replaced with a recording test view.

### 003. [MVVM (Model-View-ViewModel)](003_mvvm_comparision.md)

A view model exposes presentation state and notifies a binding when it changes.

**Scenario:** Set the input to 6; a subscription updates the displayed derived value to twice the input.

**Observation:** 12; the registered binding propagates the update to the screen.

LMX and TypeScript show one explicit notification binding; C# uses INotifyPropertyChanged. No language is credited with an unimplemented binding engine.

### 004. [Flux / Redux](004_flux_redux_comparision.md)

Actions pass through one store and a pure reducer.

**Scenario:** From state 0 dispatch +2 and +3, retaining the old value after the first step.

**Observation:** Retained value 2, current state 5, demo = 25.

TypeScript uses an action object, C# a value record, and LMX a structural call with named delta. This is unidirectional flow without a mandatory Redux dependency.

### 035. [Front Controller](035_front_controller_comparision.md)

One entry applies common policy and dispatches to a request handler.

**Scenario:** Route 1 returns 200 only when admission=1; otherwise 403. An unknown route returns 404.

**Observation:** demo = 200; extra checks: (0,1) → 403 and (1,9) → 404.

Common policy precedes endpoint selection. All listings measure the same dispatch core, excluding the HTTP host, decoding, and real authentication.

### 036. [Page Controller](036_page_controller_comparision.md)

A dedicated handler belongs to a specific page or action.

**Scenario:** An order-page handler receives quantity=3 and produces subtotal=30.

**Observation:** 30; no other page participates.

A page controller belongs to one page/action. A shared web router may precede it; it can coexist with a front controller.

### 037. [Application Controller](037_application_controller_comparision.md)

One place decides navigation between screens.

**Scenario:** On screen 1 a valid submission goes to screen 2; invalid input stays on screen 1.

**Observation:** 2 after a successful transition; (screen=1, valid=0) returns 1.

The pattern centralizes transition decisions. None of the variants automatically navigates on arbitrary model mutation.

## Boundaries

Sizes are computed from each comparison’s three listings. Paired cases count ready-component use separately from the component implementation, with the same boundary in all three languages. Runtime, HTTP hosts and databases are not hidden behind a new import. IDs 1–85 retain the supplied list, 86–90 are added patterns, and IDs above 90 identify separate library-component implementations.
