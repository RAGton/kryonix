param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ArgsList
)
uv run --project packages/kryonix-brain-lightrag rag @ArgsList
