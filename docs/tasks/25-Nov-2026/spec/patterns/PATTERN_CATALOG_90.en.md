# LMX: 90 patterns and library implementations

All 85 supplied entries and five additions remain. 9 component-implementation comparisons sit beside their clients: 99 entries in total. Functional clients 082–085 publish both LMX styles; the former 297 listings described the original three-language layout and are not the current count of all published sources. The original 23 root GoF examples remain separate.

## Groups

| Directory | Patterns | Implementations | Control languages |
| --- | ---: | ---: | --- |
| [Presentation and navigation](01_ui_and_navigation/LMX_Design_Patterns.en.md) | 7 | 0 | TypeScript, C# |
| [Architecture and component boundaries](02_architecture_and_boundaries/LMX_Design_Patterns.en.md) | 11 | 1 | Java, Go |
| [Domain model and persistence](03_domain_and_persistence/LMX_Design_Patterns.en.md) | 19 | 3 | Python, C# |
| [Events, distributed state and consistency](04_events_and_consistency/LMX_Design_Patterns.en.md) | 9 | 0 | Java, Go |
| [Cloud, HTTP and resilience](05_cloud_and_resilience/LMX_Design_Patterns.en.md) | 13 | 1 | Go, C# |
| [Asynchrony, workers and Message](06_async_and_messages/LMX_Design_Patterns.en.md) | 11 | 0 | Go, Erlang |
| [State coordination: Message and shared memory](07_state_coordination/LMX_Design_Patterns.en.md) | 6 | 0 | Java, Rust |
| [Objects, dependencies, and composition](08_objects_and_composition/LMX_Design_Patterns.en.md) | 10 | 0 | Java, Python |
| [Functional computation](09_functional_computation/LMX_Design_Patterns.en.md) | 4 | 4 | Haskell, Scala |

## Catalog with adjacent implementations

| ID | Comparison | Layer |
| ---: | --- | --- |
| 001 | [001. MVC (Model-View-Controller)](01_ui_and_navigation/001_mvc_comparision.md) | Main example |
| 002 | [002. MVP (Model-View-Presenter)](01_ui_and_navigation/002_mvp_comparision.md) | Main example |
| 003 | [003. MVVM (Model-View-ViewModel)](01_ui_and_navigation/003_mvvm_comparision.md) | Main example |
| 004 | [004. Flux / Redux](01_ui_and_navigation/004_flux_redux_comparision.md) | Main example |
| 005 | [005. Layered Architecture](02_architecture_and_boundaries/005_layered_architecture_comparision.md) | Main example |
| 006 | [006. Hexagonal Architecture (Ports and Adapters)](02_architecture_and_boundaries/006_hexagonal_architecture_comparision.md) | Main example |
| 007 | [007. Clean Architecture](02_architecture_and_boundaries/007_clean_architecture_comparision.md) | Main example |
| 008 | [008. Onion Architecture](02_architecture_and_boundaries/008_onion_architecture_comparision.md) | Main example |
| 009 | [009. Microservices](02_architecture_and_boundaries/009_microservices_comparision.md) | Main example |
| 010 | [010. Event-Driven Architecture](02_architecture_and_boundaries/010_event_driven_architecture_comparision.md) | Main example |
| 011 | [011. CQRS](04_events_and_consistency/011_cqrs_comparision.md) | Main example |
| 012 | [012. Event Sourcing](04_events_and_consistency/012_event_sourcing_comparision.md) | Main example |
| 013 | [013. Pipe and Filter](02_architecture_and_boundaries/013_pipe_and_filter_comparision.md) | Library use |
| 093 | [093. Pipe — implementation](02_architecture_and_boundaries/093_pipe_implementation_comparision.md) | Implementation |
| 014 | [014. Blackboard](02_architecture_and_boundaries/014_blackboard_comparision.md) | Main example |
| 015 | [015. Microkernel / Plug-in](02_architecture_and_boundaries/015_microkernel_comparision.md) | Main example |
| 016 | [016. Repository](03_domain_and_persistence/016_repository_comparision.md) | Library use |
| 094 | [094. FindById — implementation](03_domain_and_persistence/094_find_by_id_implementation_comparision.md) | Implementation |
| 017 | [017. Unit of Work](03_domain_and_persistence/017_unit_of_work_comparision.md) | Main example |
| 018 | [018. Data Mapper](03_domain_and_persistence/018_data_mapper_comparision.md) | Main example |
| 019 | [019. Active Record](03_domain_and_persistence/019_active_record_comparision.md) | Main example |
| 020 | [020. Table Data Gateway](03_domain_and_persistence/020_table_data_gateway_comparision.md) | Main example |
| 021 | [021. Row Data Gateway](03_domain_and_persistence/021_row_data_gateway_comparision.md) | Main example |
| 022 | [022. DAO — Data Access Object](03_domain_and_persistence/022_dao_comparision.md) | Main example |
| 023 | [023. DTO — Data Transfer Object](03_domain_and_persistence/023_dto_comparision.md) | Main example |
| 024 | [024. Domain Model](03_domain_and_persistence/024_domain_model_comparision.md) | Main example |
| 025 | [025. Transaction Script](03_domain_and_persistence/025_transaction_script_comparision.md) | Main example |
| 026 | [026. Table Module](03_domain_and_persistence/026_table_module_comparision.md) | Main example |
| 027 | [027. Service Layer](03_domain_and_persistence/027_service_layer_comparision.md) | Main example |
| 028 | [028. Identity Map](03_domain_and_persistence/028_identity_map_comparision.md) | Main example |
| 029 | [029. Lazy Load](03_domain_and_persistence/029_lazy_load_comparision.md) | Main example |
| 030 | [030. Query Object](03_domain_and_persistence/030_query_object_comparision.md) | Main example |
| 031 | [031. Specification](03_domain_and_persistence/031_specification_comparision.md) | Library use |
| 095 | [095. Specification combinator — implementation](03_domain_and_persistence/095_specification_combinator_implementation_comparision.md) | Implementation |
| 032 | [032. Value Object](03_domain_and_persistence/032_value_object_comparision.md) | Library use |
| 096 | [096. Money value equality — implementation](03_domain_and_persistence/096_money_value_equality_implementation_comparision.md) | Implementation |
| 033 | [033. Optimistic Offline Lock](03_domain_and_persistence/033_optimistic_offline_lock_comparision.md) | Main example |
| 034 | [034. Pessimistic Offline Lock](03_domain_and_persistence/034_pessimistic_offline_lock_comparision.md) | Main example |
| 035 | [035. Front Controller](01_ui_and_navigation/035_front_controller_comparision.md) | Main example |
| 036 | [036. Page Controller](01_ui_and_navigation/036_page_controller_comparision.md) | Main example |
| 037 | [037. Application Controller](01_ui_and_navigation/037_application_controller_comparision.md) | Main example |
| 038 | [038. Circuit Breaker](05_cloud_and_resilience/038_circuit_breaker_comparision.md) | Main example |
| 039 | [039. Retry](05_cloud_and_resilience/039_retry_comparision.md) | Library use |
| 097 | [097. Retry Library — Implementation](05_cloud_and_resilience/097_retry_library_implementation_comparision.md) | Implementation |
| 040 | [040. Bulkhead](05_cloud_and_resilience/040_bulkhead_comparision.md) | Main example |
| 041 | [041. Saga](04_events_and_consistency/041_saga_comparision.md) | Main example |
| 042 | [042. API Gateway](05_cloud_and_resilience/042_api_gateway_comparision.md) | Main example |
| 043 | [043. Backends for Frontends](05_cloud_and_resilience/043_backends_for_frontends_comparision.md) | Main example |
| 044 | [044. Sidecar](05_cloud_and_resilience/044_sidecar_comparision.md) | Main example |
| 045 | [045. Ambassador](05_cloud_and_resilience/045_ambassador_comparision.md) | Library use |
| 046 | [046. Anti-Corruption Layer (ACL)](02_architecture_and_boundaries/046_anti_corruption_layer_comparision.md) | Main example |
| 047 | [047. Strangler Fig](02_architecture_and_boundaries/047_strangler_fig_comparision.md) | Main example |
| 048 | [048. Transactional Outbox](04_events_and_consistency/048_transactional_outbox_comparision.md) | Main example |
| 049 | [049. Cache-Aside](05_cloud_and_resilience/049_cache_aside_comparision.md) | Main example |
| 050 | [050. Materialized View](04_events_and_consistency/050_materialized_view_comparision.md) | Main example |
| 051 | [051. Sharding](04_events_and_consistency/051_sharding_comparision.md) | Main example |
| 052 | [052. Throttling](05_cloud_and_resilience/052_throttling_comparision.md) | Main example |
| 053 | [053. Queue-Based Load Leveling](05_cloud_and_resilience/053_queue_based_load_leveling_comparision.md) | Main example |
| 054 | [054. Competing Consumers](05_cloud_and_resilience/054_competing_consumers_comparision.md) | Main example |
| 055 | [055. Leader Election](04_events_and_consistency/055_leader_election_comparision.md) | Main example |
| 056 | [056. Health Endpoint Monitoring](05_cloud_and_resilience/056_health_endpoint_monitoring_comparision.md) | Main example |
| 057 | [057. Claim Check](04_events_and_consistency/057_claim_check_comparision.md) | Main example |
| 058 | [058. Thread Pool](06_async_and_messages/058_thread_pool_comparision.md) | Main example |
| 059 | [059. Producer-Consumer](06_async_and_messages/059_producer_consumer_comparision.md) | Main example |
| 060 | [060. Actor Model](06_async_and_messages/060_actor_model_comparision.md) | Main example |
| 061 | [061. Active Object](06_async_and_messages/061_active_object_comparision.md) | Main example |
| 062 | [062. Reactor](06_async_and_messages/062_reactor_comparision.md) | Main example |
| 063 | [063. Proactor](06_async_and_messages/063_proactor_comparision.md) | Main example |
| 064 | [064. Future / Promise](06_async_and_messages/064_future_promise_comparision.md) | Main example |
| 065 | [065. Read-Write Lock](07_state_coordination/065_read_write_lock_comparision.md) | Main example |
| 066 | [066. Double-Checked Locking](07_state_coordination/066_double_checked_locking_comparision.md) | Main example |
| 067 | [067. Guarded Suspension](07_state_coordination/067_guarded_suspension_comparision.md) | Main example |
| 068 | [068. Balking](07_state_coordination/068_balking_comparision.md) | Main example |
| 069 | [069. Thread-Local Storage](07_state_coordination/069_thread_local_storage_comparision.md) | Main example |
| 070 | [070. Monitor Object](07_state_coordination/070_monitor_object_comparision.md) | Main example |
| 071 | [071. Half-Sync / Half-Async](06_async_and_messages/071_half_sync_half_async_comparision.md) | Main example |
| 072 | [072. Dependency Injection](08_objects_and_composition/072_dependency_injection_comparision.md) | Main example |
| 073 | [073. Service Locator](08_objects_and_composition/073_service_locator_comparision.md) | Main example |
| 074 | [074. Null Object](08_objects_and_composition/074_null_object_comparision.md) | Main example |
| 075 | [075. Object Pool](08_objects_and_composition/075_object_pool_comparision.md) | Main example |
| 076 | [076. Simple Factory](08_objects_and_composition/076_simple_factory_comparision.md) | Main example |
| 077 | [077. Multiton](08_objects_and_composition/077_multiton_comparision.md) | Main example |
| 078 | [078. Marker Interface](08_objects_and_composition/078_marker_interface_comparision.md) | Main example |
| 079 | [079. Fluent Interface](08_objects_and_composition/079_fluent_interface_comparision.md) | Main example |
| 080 | [080. Type Object](08_objects_and_composition/080_type_object_comparision.md) | Main example |
| 081 | [081. Extension Object](08_objects_and_composition/081_extension_object_comparision.md) | Main example |
| 082 | [082. Monad](09_functional_computation/082_monad_comparision.md) | Library use |
| 091 | [091. Maybe container and bind implementation](09_functional_computation/091_maybe_container_and_bind_implementation_comparision.md) | Implementation |
| 083 | [083. Trampoline](09_functional_computation/083_trampoline_comparision.md) | Library use |
| 092 | [092. Trampoline container and runner implementation](09_functional_computation/092_trampoline_container_and_runner_implementation_comparision.md) | Implementation |
| 084 | [084. Execute Around](09_functional_computation/084_execute_around_comparision.md) | Library use |
| 098 | [098. Execute Around implementation](09_functional_computation/098_execute_around_implementation_comparision.md) | Implementation |
| 085 | [085. Currying](09_functional_computation/085_currying_comparision.md) | Library use |
| 099 | [099. Integer partial-application implementation](09_functional_computation/099_integer_partial_application_implementation_comparision.md) | Implementation |
| 086 | [086. Idempotent Consumer / Transactional Inbox](04_events_and_consistency/086_idempotent_consumer_inbox_comparision.md) | Main example |
| 087 | [087. Backpressure](05_cloud_and_resilience/087_backpressure_comparision.md) | Main example |
| 088 | [088. Structured Concurrency](06_async_and_messages/088_structured_concurrency_comparision.md) | Main example |
| 089 | [089. Supervision Tree](06_async_and_messages/089_supervision_tree_comparision.md) | Main example |
| 090 | [090. MapReduce](06_async_and_messages/090_map_reduce_comparision.md) | Main example |

[Methodology](COMPARISON_METHODOLOGY.en.md) · [Libraries](LIBRARY_COMPONENTS.md) · [Audit](OPERAND_LIBRARY_REVIEW.md) · [Validation](VALIDATION.md)

## Extension: algorithms and patterns 100–108

[Алгоритмы / Algorithms](10_algorithms/README.md) · [Состояние и симуляции / State and simulation](11_state_and_simulation_patterns/README.md) · [Обзор всей текущей редакции](EXPANSION_2026-11-24.md).

Исходные 90 пунктов выше сохранены; 100–105 добавляют распространённые алгоритмы, 106–108 — Double Buffer, Dirty Flag и Fixed Timestep. Для каждого нового сценария указаны два подходящих контрольных языка и обе LMX-формы.
