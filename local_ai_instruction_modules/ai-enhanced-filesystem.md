# Enhanced Filesystem Tool Configuration

## Overview
This document provides comprehensive configuration and usage patterns for maximizing filesystem operation capabilities in Claude Code environments using available MCP servers and built-in tools.

## Available Filesystem Tool Ecosystem

### Tier 1: MCP Filesystem Server Tools
**Prefix**: `mcp__filesystem__*`

| Tool | Purpose | Best Use Case |
|------|---------|---------------|
| `read_text_file` | Read file contents as text | Single file analysis |
| `read_multiple_files` | Read multiple files simultaneously | Batch file analysis |
| `write_file` | Create/overwrite files | New file creation |
| `edit_file` | Line-based file editing | Precise modifications |
| `create_directory` | Create directory structures | Project scaffolding |
| `list_directory` | List directory contents | Structure exploration |
| `search_files` | Search files by pattern | File discovery |
| `move_file` | Move/rename files | File organization |
| `get_file_info` | Get file metadata | File inspection |
| `list_allowed_directories` | Show accessible paths | Permission verification |

### Tier 2: Desktop Commander Tools
**Prefix**: `mcp__desktop-commander__*`

| Tool | Purpose | Advanced Features |
|------|---------|-------------------|
| `read_file` | Advanced file reading | Offset/length support, URL fetching |
| `read_multiple_files` | Batch file operations | Parallel processing |
| `write_file` | Chunked file writing | 25-30 line chunking (best practice) |
| `edit_block` | Surgical text replacement | Exact string matching |
| `start_search` | Streaming file search | Real-time results, content/filename modes |
| `get_more_search_results` | Paginated search results | Offset-based pagination |
| `stop_search` | Terminate active searches | Resource management |
| `list_searches` | Monitor active searches | Multi-search management |

### Tier 3: Built-in Claude Code Tools
**No Prefix**: Direct tool names

| Tool | Purpose | Key Features |
|------|---------|--------------|
| `Read` | File reading with line control | Line offset/limit support |
| `Write` | File creation/overwriting | Requires prior Read for existing files |
| `Edit` | Exact string replacement | Context-aware editing |
| `MultiEdit` | Multiple edits per file | Atomic multi-operation editing |
| `Glob` | Pattern-based file discovery | Fast file pattern matching |
| `Grep` | Content search with regex | Powerful search with context |

## Enhanced Configuration Patterns

### MCP Server Configuration Template
Create or update `~/.config/claude-desktop/mcp_servers.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "env": {
        "FILESYSTEM_ALLOWED_PATHS": "/home/user/projects,/workspace,/tmp"
      }
    },
    "filesystem-extended": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem-extended"],
      "env": {
        "FILESYSTEM_ROOT": "/",
        "FILESYSTEM_ENABLE_WRITE": "true",
        "FILESYSTEM_ENABLE_SEARCH": "true"
      }
    },
    "desktop-commander": {
      "command": "desktop-commander",
      "args": ["--mcp"],
      "env": {
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

### Optimal Tool Selection Strategy

#### File Reading Operations
1. **Single file < 2000 lines**: Use `Read` tool (built-in)
2. **Single file with specific range**: Use `mcp__desktop-commander__read_file` with offset/length
3. **Multiple related files**: Use `mcp__filesystem__read_multiple_files`
4. **Large file analysis**: Use `mcp__desktop-commander__read_file` with chunking

#### File Writing Operations
1. **New small files**: Use `Write` tool (built-in)
2. **Large files**: Use `mcp__desktop-commander__write_file` with 25-30 line chunks
3. **File modifications**: Use `Edit` or `mcp__desktop-commander__edit_block`
4. **Multiple file edits**: Use `MultiEdit` for atomic operations

#### File Discovery Operations
1. **Pattern matching**: Use `Glob` tool (fastest)
2. **Content search**: Use `Grep` tool with regex
3. **Interactive search**: Use `mcp__desktop-commander__start_search` for large directories
4. **Advanced filters**: Use `mcp__filesystem__search_files`

### Performance Optimization Patterns

#### Chunked File Operations
```markdown
## Best Practice: Always chunk large files
1. FIRST → write_file(filePath, firstChunk, {mode: 'rewrite'}) [≤30 lines]
2. THEN → write_file(filePath, secondChunk, {mode: 'append'}) [≤30 lines]
3. CONTINUE → write_file(filePath, nextChunk, {mode: 'append'}) [≤30 lines]
```

#### Batch Operations
```markdown
## Efficient Multi-File Handling
- Use read_multiple_files for related file analysis
- Use streaming search for large directory exploration
- Combine Glob + Read for pattern-based file processing
- Use parallel Desktop Commander operations when available
```

#### Search Strategy
```markdown
## Layered Search Approach
1. Glob for filename patterns (fastest)
2. Grep for content with specific files
3. Desktop Commander streaming search for exploration
4. MCP filesystem search for complex filters
```

## Advanced Usage Patterns

### Project Analysis Workflow
```markdown
1. list_allowed_directories() # Verify access
2. Glob("**/*.{js,ts,py}") # Find source files
3. read_multiple_files(sourceFiles[:10]) # Sample analysis
4. start_search(content, "TODO|FIXME|HACK") # Find issues
5. get_more_search_results() # Process results
```

### Large File Processing Workflow
```markdown
1. get_file_info(filePath) # Check size/metadata
2. read_file(filePath, offset=0, length=100) # Preview
3. start_search(filePath, pattern) # Stream search
4. edit_block(filePath, targetText, newText) # Surgical edits
```

### Project Scaffolding Workflow
```markdown
1. create_directory("src/components")
2. create_directory("tests/unit")
3. write_file("src/index.js", template) # Chunked if large
4. read_text_file("template.json") # Read configuration
5. write_file("package.json", processedConfig)
```

## Integration with Delegation Mandate

### Agent-Filesystem Tool Mapping
- **devops-engineer**: Infrastructure files, Docker, CI/CD configurations
- **github_ops_expert**: GitHub repository settings, branch policies, workflow metadata
- **backend-developer**: Source code, API files, database schemas
- **frontend-developer**: UI components, stylesheets, asset files
- **documentation-expert**: README, docs, API documentation
- **qa-test-engineer**: Test files, test configurations

### Delegation Patterns
```markdown
## Filesystem Operation Delegation
- File structure creation → devops-engineer
- Repository automation metadata → github_ops_expert
- Code file generation → backend-developer/frontend-developer
- Documentation creation → documentation-expert
- Test file creation → qa-test-engineer
- Configuration management → devops-engineer
```

## Error Handling and Fallbacks

### Tool Availability Checks
```markdown
1. Try MCP filesystem tools first (most capable)
2. Fall back to Desktop Commander (if MCP unavailable)
3. Use built-in Claude Code tools (always available)
4. Document tool limitations and workarounds
```

### Permission Management
```markdown
1. Use list_allowed_directories() to verify access
2. Handle permission errors gracefully
3. Request directory allowlist updates when needed
4. Document access limitations in delegation context
```

### Performance Considerations
```markdown
1. Monitor file sizes before operations
2. Use chunking for files >50 lines
3. Implement search timeouts for large directories
4. Cache frequently accessed file contents
```

## Monitoring and Metrics

### Operation Tracking
- Track filesystem operation success/failure rates
- Monitor performance of different tool tiers
- Document tool selection effectiveness
- Measure delegation vs direct execution ratios

### Quality Metrics
- File operation accuracy (successful edits/total attempts)
- Search effectiveness (relevant results/total results)
- Performance benchmarks (operations per second)
- Error recovery success rates

This enhanced filesystem configuration maximizes the effectiveness of available tools while supporting the delegation mandate requirements for efficient, distributed file operations.