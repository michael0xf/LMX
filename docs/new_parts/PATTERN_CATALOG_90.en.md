# LMX: catalog of 90 additional patterns

All 85 supplied entries retain their IDs. Entries 86–90 are additions. The original root collection of 23 GoF patterns remains separate.

## Groups and control languages

| Directory | Group | Patterns | Control languages |
| --- | --- | ---: | --- |
| [01_ui_and_navigation](01_ui_and_navigation/LMX_Design_Patterns.en.md) | Presentation and navigation | 7 | TypeScript, C# |
| [02_architecture_and_boundaries](02_architecture_and_boundaries/LMX_Design_Patterns.en.md) | Architecture and component boundaries | 11 | Java, Go |
| [03_domain_and_persistence](03_domain_and_persistence/LMX_Design_Patterns.en.md) | Domain model and persistence | 19 | Python, C# |
| [04_events_and_consistency](04_events_and_consistency/LMX_Design_Patterns.en.md) | Events, distributed state and consistency | 9 | Java, Go |
| [05_cloud_and_resilience](05_cloud_and_resilience/LMX_Design_Patterns.en.md) | Cloud, HTTP and resilience | 13 | Go, C# |
| [06_async_and_messages](06_async_and_messages/LMX_Design_Patterns.en.md) | Asynchrony, workers and Message | 11 | Go, Erlang |
| [07_state_coordination](07_state_coordination/LMX_Design_Patterns.en.md) | State coordination: Message and shared memory | 6 | Java, Rust |
| [08_objects_and_composition](08_objects_and_composition/LMX_Design_Patterns.en.md) | Objects, dependencies, and composition | 10 | Java, Python |
| [09_functional_computation](09_functional_computation/LMX_Design_Patterns.en.md) | Functional computation | 4 | Haskell, Scala |

## All entries

| ID | Pattern | Group |
| ---: | --- | --- |
| 001 | [MVC (Model-View-Controller)](01_ui_and_navigation/001_mvc_comparision.md) | Presentation and navigation |
| 002 | [MVP (Model-View-Presenter)](01_ui_and_navigation/002_mvp_comparision.md) | Presentation and navigation |
| 003 | [MVVM (Model-View-ViewModel)](01_ui_and_navigation/003_mvvm_comparision.md) | Presentation and navigation |
| 004 | [Flux / Redux](01_ui_and_navigation/004_flux_redux_comparision.md) | Presentation and navigation |
| 005 | [Layered Architecture](02_architecture_and_boundaries/005_layered_architecture_comparision.md) | Architecture and component boundaries |
| 006 | [Hexagonal Architecture (Ports and Adapters)](02_architecture_and_boundaries/006_hexagonal_architecture_comparision.md) | Architecture and component boundaries |
| 007 | [Clean Architecture](02_architecture_and_boundaries/007_clean_architecture_comparision.md) | Architecture and component boundaries |
| 008 | [Onion Architecture](02_architecture_and_boundaries/008_onion_architecture_comparision.md) | Architecture and component boundaries |
| 009 | [Microservices](02_architecture_and_boundaries/009_microservices_comparision.md) | Architecture and component boundaries |
| 010 | [Event-Driven Architecture](02_architecture_and_boundaries/010_event_driven_architecture_comparision.md) | Architecture and component boundaries |
| 011 | [CQRS](04_events_and_consistency/011_cqrs_comparision.md) | Events, distributed state and consistency |
| 012 | [Event Sourcing](04_events_and_consistency/012_event_sourcing_comparision.md) | Events, distributed state and consistency |
| 013 | [Pipe and Filter](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | Architecture and component boundaries |
| 014 | [Blackboard](02_architecture_and_boundaries/014_blackboard_comparision.md) | Architecture and component boundaries |
| 015 | [Microkernel / Plug-in](02_architecture_and_boundaries/015_microkernel_comparision.md) | Architecture and component boundaries |
| 016 | [Repository](03_domain_and_persistence/016_repository_comparision.md) | Domain model and persistence |
| 017 | [Unit of Work](03_domain_and_persistence/017_unit_of_work_comparision.md) | Domain model and persistence |
| 018 | [Data Mapper](03_domain_and_persistence/018_data_mapper_comparision.md) | Domain model and persistence |
| 019 | [Active Record](03_domain_and_persistence/019_active_record_comparision.md) | Domain model and persistence |
| 020 | [Table Data Gateway](03_domain_and_persistence/020_table_data_gateway_comparision.md) | Domain model and persistence |
| 021 | [Row Data Gateway](03_domain_and_persistence/021_row_data_gateway_comparision.md) | Domain model and persistence |
| 022 | [DAO — Data Access Object](03_domain_and_persistence/022_dao_comparision.md) | Domain model and persistence |
| 023 | [DTO — Data Transfer Object](03_domain_and_persistence/023_dto_comparision.md) | Domain model and persistence |
| 024 | [Domain Model](03_domain_and_persistence/024_domain_model_comparision.md) | Domain model and persistence |
| 025 | [Transaction Script](03_domain_and_persistence/025_transaction_script_comparision.md) | Domain model and persistence |
| 026 | [Table Module](03_domain_and_persistence/026_table_module_comparision.md) | Domain model and persistence |
| 027 | [Service Layer](03_domain_and_persistence/027_service_layer_comparision.md) | Domain model and persistence |
| 028 | [Identity Map](03_domain_and_persistence/028_identity_map_comparision.md) | Domain model and persistence |
| 029 | [Lazy Load](03_domain_and_persistence/029_lazy_load_comparision.md) | Domain model and persistence |
| 030 | [Query Object](03_domain_and_persistence/030_query_object_comparision.md) | Domain model and persistence |
| 031 | [Specification](03_domain_and_persistence/031_specification_comparision.md) | Domain model and persistence |
| 032 | [Value Object](03_domain_and_persistence/032_value_object_comparision.md) | Domain model and persistence |
| 033 | [Optimistic Offline Lock](03_domain_and_persistence/033_optimistic_offline_lock_comparision.md) | Domain model and persistence |
| 034 | [Pessimistic Offline Lock](03_domain_and_persistence/034_pessimistic_offline_lock_comparision.md) | Domain model and persistence |
| 035 | [Front Controller](01_ui_and_navigation/035_front_controller_comparision.md) | Presentation and navigation |
| 036 | [Page Controller](01_ui_and_navigation/036_page_controller_comparision.md) | Presentation and navigation |
| 037 | [Application Controller](01_ui_and_navigation/037_application_controller_comparision.md) | Presentation and navigation |
| 038 | [Circuit Breaker](05_cloud_and_resilience/038_circuit_breaker_comparision.md) | Cloud, HTTP and resilience |
| 039 | [Retry](05_cloud_and_resilience/039_retry_comparision.md) | Cloud, HTTP and resilience |
| 040 | [Bulkhead](05_cloud_and_resilience/040_bulkhead_comparision.md) | Cloud, HTTP and resilience |
| 041 | [Saga](04_events_and_consistency/041_saga_comparision.md) | Events, distributed state and consistency |
| 042 | [API Gateway](05_cloud_and_resilience/042_api_gateway_comparision.md) | Cloud, HTTP and resilience |
| 043 | [Backends for Frontends](05_cloud_and_resilience/043_backends_for_frontends_comparision.md) | Cloud, HTTP and resilience |
| 044 | [Sidecar](05_cloud_and_resilience/044_sidecar_comparision.md) | Cloud, HTTP and resilience |
| 045 | [Ambassador](05_cloud_and_resilience/045_ambassador_comparision.md) | Cloud, HTTP and resilience |
| 046 | [Anti-Corruption Layer (ACL)](02_architecture_and_boundaries/046_anti_corruption_layer_comparision.md) | Architecture and component boundaries |
| 047 | [Strangler Fig](02_architecture_and_boundaries/047_strangler_fig_comparision.md) | Architecture and component boundaries |
| 048 | [Transactional Outbox](04_events_and_consistency/048_transactional_outbox_comparision.md) | Events, distributed state and consistency |
| 049 | [Cache-Aside](05_cloud_and_resilience/049_cache_aside_comparision.md) | Cloud, HTTP and resilience |
| 050 | [Materialized View](04_events_and_consistency/050_materialized_view_comparision.md) | Events, distributed state and consistency |
| 051 | [Sharding](04_events_and_consistency/051_sharding_comparision.md) | Events, distributed state and consistency |
| 052 | [Throttling](05_cloud_and_resilience/052_throttling_comparision.md) | Cloud, HTTP and resilience |
| 053 | [Queue-Based Load Leveling](05_cloud_and_resilience/053_queue_based_load_leveling_comparision.md) | Cloud, HTTP and resilience |
| 054 | [Competing Consumers](05_cloud_and_resilience/054_competing_consumers_comparision.md) | Cloud, HTTP and resilience |
| 055 | [Leader Election](04_events_and_consistency/055_leader_election_comparision.md) | Events, distributed state and consistency |
| 056 | [Health Endpoint Monitoring](05_cloud_and_resilience/056_health_endpoint_monitoring_comparision.md) | Cloud, HTTP and resilience |
| 057 | [Claim Check](04_events_and_consistency/057_claim_check_comparision.md) | Events, distributed state and consistency |
| 058 | [Thread Pool](06_async_and_messages/058_thread_pool_comparision.md) | Asynchrony, workers and Message |
| 059 | [Producer-Consumer](06_async_and_messages/059_producer_consumer_comparision.md) | Asynchrony, workers and Message |
| 060 | [Actor Model](06_async_and_messages/060_actor_model_comparision.md) | Asynchrony, workers and Message |
| 061 | [Active Object](06_async_and_messages/061_active_object_comparision.md) | Asynchrony, workers and Message |
| 062 | [Reactor](06_async_and_messages/062_reactor_comparision.md) | Asynchrony, workers and Message |
| 063 | [Proactor](06_async_and_messages/063_proactor_comparision.md) | Asynchrony, workers and Message |
| 064 | [Future / Promise](06_async_and_messages/064_future_promise_comparision.md) | Asynchrony, workers and Message |
| 065 | [Read-Write Lock](07_state_coordination/065_read_write_lock_comparision.md) | State coordination: Message and shared memory |
| 066 | [Double-Checked Locking](07_state_coordination/066_double_checked_locking_comparision.md) | State coordination: Message and shared memory |
| 067 | [Guarded Suspension](07_state_coordination/067_guarded_suspension_comparision.md) | State coordination: Message and shared memory |
| 068 | [Balking](07_state_coordination/068_balking_comparision.md) | State coordination: Message and shared memory |
| 069 | [Thread-Local Storage](07_state_coordination/069_thread_local_storage_comparision.md) | State coordination: Message and shared memory |
| 070 | [Monitor Object](07_state_coordination/070_monitor_object_comparision.md) | State coordination: Message and shared memory |
| 071 | [Half-Sync / Half-Async](06_async_and_messages/071_half_sync_half_async_comparision.md) | Asynchrony, workers and Message |
| 072 | [Dependency Injection](08_objects_and_composition/072_dependency_injection_comparision.md) | Objects, dependencies, and composition |
| 073 | [Service Locator](08_objects_and_composition/073_service_locator_comparision.md) | Objects, dependencies, and composition |
| 074 | [Null Object](08_objects_and_composition/074_null_object_comparision.md) | Objects, dependencies, and composition |
| 075 | [Object Pool](08_objects_and_composition/075_object_pool_comparision.md) | Objects, dependencies, and composition |
| 076 | [Simple Factory](08_objects_and_composition/076_simple_factory_comparision.md) | Objects, dependencies, and composition |
| 077 | [Multiton](08_objects_and_composition/077_multiton_comparision.md) | Objects, dependencies, and composition |
| 078 | [Marker Interface](08_objects_and_composition/078_marker_interface_comparision.md) | Objects, dependencies, and composition |
| 079 | [Fluent Interface](08_objects_and_composition/079_fluent_interface_comparision.md) | Objects, dependencies, and composition |
| 080 | [Type Object](08_objects_and_composition/080_type_object_comparision.md) | Objects, dependencies, and composition |
| 081 | [Extension Object](08_objects_and_composition/081_extension_object_comparision.md) | Objects, dependencies, and composition |
| 082 | [Monad](09_functional_computation/082_monad_comparision.md) | Functional computation |
| 083 | [Trampoline](09_functional_computation/083_trampoline_comparision.md) | Functional computation |
| 084 | [Execute Around](09_functional_computation/084_execute_around_comparision.md) | Functional computation |
| 085 | [Currying](09_functional_computation/085_currying_comparision.md) | Functional computation |
| 086 | [Idempotent Consumer / Transactional Inbox](04_events_and_consistency/086_idempotent_consumer_inbox_comparision.md) | Events, distributed state and consistency |
| 087 | [Backpressure](05_cloud_and_resilience/087_backpressure_comparision.md) | Cloud, HTTP and resilience |
| 088 | [Structured Concurrency](06_async_and_messages/088_structured_concurrency_comparision.md) | Asynchrony, workers and Message |
| 089 | [Supervision Tree](06_async_and_messages/089_supervision_tree_comparision.md) | Asynchrony, workers and Message |
| 090 | [MapReduce](06_async_and_messages/090_map_reduce_comparision.md) | Asynchrony, workers and Message |

## Additions

- **86: Idempotent Consumer / Transactional Inbox.**
- **87: Backpressure.**
- **88: Structured Concurrency.**
- **89: Supervision Tree.**
- **90: MapReduce.**

[Methodology](COMPARISON_METHODOLOGY.en.md) · [Sources](SOURCE_INDEX.md) · [Validation](VALIDATION.md)
