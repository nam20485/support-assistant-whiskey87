# Architecture (Plan)

## Overview

SupportAssistant is a privacy-first Windows desktop assistant that answers troubleshooting questions using an on-device LLM grounded by a curated local knowledge base (RAG). It can propose and (only with explicit user approval) execute safe, granular system modifications via a constrained tool layer.

## Core Principles

- Offline-first: core features work without network connectivity.
- Privacy-first: prompts/diagnostics stay on-device.
- Human-in-the-loop: no system-modifying actions without explicit user confirmation.
- Verifiability: answers must cite/trace back to retrieved sources.

## High-Level Components

1. **UI (Avalonia, MVVM)**
   - Chat surface + history
   - “Proposed Actions” review/approve UI
   - Settings (model selection, hardware accel, KB updates)

2. **Conversation / Orchestration Layer**
   - Maintains conversation state
   - Builds prompts with retrieved context
   - Handles tool-calling loop (plan → propose actions → request approval → execute)

3. **Inference Layer**
   - Loads Phi-3-mini (ONNX)
   - Executes with ONNX Runtime (DirectML) and/or Windows ML
   - Provides streaming token output (if supported)

4. **Retrieval Layer (RAG)**
   - Chunked knowledge base content + provenance
   - Embedding generation for queries/doc chunks
   - Local similarity search (vector index)
   - Returns top-K sources to augment prompts

5. **Tool/Action Execution Layer (Agentic)**
   - Strongly-typed, narrowly-scoped tools (e.g., registry edits, file edits)
   - JSON schema validation of model tool call outputs
   - Dry-run/preview generation
   - Auditing + rollback support (backups, restore points where feasible)

6. **Persistence**
   - Local storage for:
     - chat sessions
     - KB chunks + metadata
     - vector index
     - audit log of executed actions
   - Initial plan: SQLite for structured data; vector index persistence TBD

## Data Flow (Typical Query)

1. User asks a question in chat.
2. Query is embedded and searched against the local vector index.
3. Retrieved snippets + citations are appended to the prompt.
4. LLM generates:
   - an answer grounded in sources, and/or
   - a proposed tool call plan (JSON) when an action is requested.
5. UI shows proposed actions → user approves/rejects.
6. Approved actions are executed through the tool layer and logged.

## Planned Project Structure

```
src/
  SupportAssistant.App/        # Avalonia app + composition root
  SupportAssistant.UI/         # Views/ViewModels
  SupportAssistant.Core/       # domain models, interfaces
  SupportAssistant.AI/         # inference, prompting, orchestration
  SupportAssistant.Retrieval/  # embeddings, vector search, KB ingestion
  SupportAssistant.Tools/      # tool definitions + execution + safety
  SupportAssistant.Storage/    # SQLite + persistence abstractions
tests/
  SupportAssistant.*.Tests/
docs/
scripts/
docker/
```

## Security Notes (Plan)

- Every tool call must be validated against a strict schema.
- Tools must be least-privilege and narrowly scoped.
- All modifications must be previewable and reversible when feasible.
- Maintain an audit log of every action (including user approval).
