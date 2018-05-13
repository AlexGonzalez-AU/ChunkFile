function Split-File {
    
    [CmdLetBinding()]

    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$false,Position=0)]
        [String]$FilePath,
        [parameter(Mandatory=$true,ValueFromPipeline=$false,Position=1)]
        [int]$ChunkBytes
    )

    $iStream = [System.IO.File]::OpenRead($FilePath)
    $chunkLength = New-Object byte[] $ChunkBytes
    $chunkCount = 0

    while ($bytesRead = $iStream.Read($chunkLength, 0, $ChunkBytes)) {
        $oStream = [System.IO.File]::OpenWrite(("{0}.chunk{1}" -f $FilePath, $chunkCount))
        $ostream.Write($chunkLength, 0, $bytesRead)
        $ostream.close()
        $chunkCount += 1
    }
}

function Join-File {
    
    [CmdLetBinding()]

    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$false,Position=0)]
        [String]$FirstChunkFilePath
    )

    $oStream = [System.IO.File]::OpenWrite($FirstChunkFilePath)
    $chunkCount = 0

    while (Test-Path -Path ("{0}.chunk{1}" -f $FirstChunkFilePath, $chunkCount)) {
        $bytesRead = [System.IO.File]::ReadAllBytes(("{0}.chunk{1}" -f $FirstChunkFilePath, $chunkCount))
        $oStream.Write($bytesRead, 0, $bytesRead.Count)
        $chunkCount += 1
    }
    
    $oStream.close()
}