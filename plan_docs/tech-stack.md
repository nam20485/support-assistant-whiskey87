# Tech Stack (Plan)

## Target Platform

- Windows 10/11
- Architectures: x64 + ARM64
- Preferred environment: Windows 11 24H2+ (to leverage Windows ML when available)

## Languages / Runtimes

- C# / .NET (pin via `global.json`)
- PowerShell for repo automation scripts

## UI

- Avalonia UI (MVVM)
- MVVM Toolkit: `CommunityToolkit.Mvvm`

## AI / ML

- Primary local LLM: Microsoft Phi-3-mini (ONNX)
- Inference runtime: ONNX Runtime
  - Hardware acceleration: `Microsoft.ML.OnnxRuntime.DirectML`
  - Optional OS integration (Win11 24H2+): Windows ML via `Microsoft.Windows.AI.MachineLearning`

## RAG / Retrieval

- Local embeddings model (ONNX) for query/doc embeddings (exact model TBD)
- Local vector index persisted on disk (implementation TBD)
- Storage:
  - `Microsoft.Data.Sqlite` for metadata + document chunks + provenance

## Agent Orchestration / Tooling

- Orchestration: `Microsoft.SemanticKernel` or `Microsoft.Extensions.AI`
- Strongly-typed tool layer (C# functions) with JSON-schema validation

## Observability

- Logging: Serilog
- Tracing/Metrics: OpenTelemetry (where appropriate)

## Testing

- Unit tests: xUnit
- Assertions: FluentAssertions
- Mocking: NSubstitute
- UI testing (later phase): TBD (Avalonia testing helpers)

## Packaging / Distribution

- MSIX (preferred)
- Code signing (later)
- Optional alternative installer for non-Store distribution (TBD)

## CI/CD & Security

- GitHub Actions: build/test/lint/scan
- Secret scanning + dependency scanning
