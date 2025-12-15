# SupportAssistant

A privacy-first Windows desktop assistant that answers troubleshooting questions using an on-device LLM grounded by a curated local knowledge base (RAG).

## Technology Stack

- **Platform**: Windows 10/11 (x64 + ARM64)
- **Language**: C# / .NET 9.0
- **UI**: Avalonia UI with MVVM pattern
- **AI/ML**: Microsoft Phi-3-mini (ONNX) with ONNX Runtime + DirectML
- **Data**: SQLite for persistence, local vector index for RAG
- **Logging**: Serilog
- **Testing**: xUnit, FluentAssertions, NSubstitute

## Project Structure

```
src/
  SupportAssistant.App/        # Avalonia application entry point
  SupportAssistant.UI/         # Views/ViewModels
  SupportAssistant.Core/       # Domain models and interfaces
  SupportAssistant.AI/         # Inference, prompting, orchestration
  SupportAssistant.Retrieval/  # RAG functionality (embeddings, search)
  SupportAssistant.Tools/      # Tool execution layer
  SupportAssistant.Storage/    # Data persistence abstractions
```

## Quick Start

### Prerequisites

- .NET 9.0 SDK
- Windows 10/11
- Visual Studio 2022 or VS Code

### Build Instructions

1. Clone the repository
2. Navigate to the root directory
3. Restore dependencies:
   ```bash
   dotnet restore
   ```
4. Build the solution:
   ```bash
   dotnet build
   ```
5. Run the application:
   ```bash
   dotnet run --project src\SupportAssistant.App
   ```

## Development Status

This project is currently in the foundation phase. The architecture and planning documents are available in the `plan_docs/` directory.

## Related Links

- [Application Plan Issue](https://github.com/nam20485/support-assistant-whiskey87/issues/2)
- [GitHub Project Board](https://github.com/users/nam20485/projects/40)

## License

See LICENSE.md for license information.
