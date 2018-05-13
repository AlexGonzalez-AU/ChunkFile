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

    $fileLength = Get-ChildItem -Path $FilePath |
        Select-Object -ExpandProperty Length

    $nChunks = [math]::Round($fileLength / $ChunkBytes)
    $divRem = 0
    [math]::DivRem($fileLength, $ChunkBytes, [ref]$divRem)
    if ($divRem -gt 0) {
        $nChunks += 1
    }

    while ($bytesRead = $iStream.Read($chunkLength, 0, $ChunkBytes)) {
        Write-Progress -Activity ("Reading file '{0}'..." -f $filePath) -Status ("Creating chunk {0} of {1}" -f ($chunkCount + 1), $nChunks) -CurrentOperation ("{0}.chunk{1}" -f $filePath, $chunkCount) -PercentComplete ($chunkCount / $nChunks * 100)
        $oStream = [System.IO.File]::OpenWrite(("{0}.chunk{1}" -f $FilePath, $chunkCount))
        $ostream.Write($chunkLength, 0, $bytesRead)
        $ostream.close()
        $chunkCount += 1
    }

    $iStream.close()
}

function Join-File {
    
    [CmdLetBinding()]

    param(
        [parameter(Mandatory=$true,ValueFromPipeline=$false,Position=0)]
        [String]$FirstChunkFilePath
    )

    $filePath = $FirstChunkFilePath.Replace('.chunk0','')

    $nChunks = Get-ChildItem -Path ("{0}.chunk*" -f $filepath) | 
        Measure-Object | 
        Select-Object -ExpandProperty count

    $oStream = [System.IO.File]::OpenWrite($filePath)
    $chunkCount = 0

    while (Test-Path -Path ("{0}.chunk{1}" -f $filePath, $chunkCount)) {
        Write-Progress -Activity ("Creating file '{0}'..." -f $filePath) -Status ("Reading chunk {0} of {1}" -f ($chunkCount + 1), $nChunks) -CurrentOperation ("{0}.chunk{1}" -f $filePath, $chunkCount) -PercentComplete ($chunkCount / $nChunks * 100)
        $bytesRead = [System.IO.File]::ReadAllBytes(("{0}.chunk{1}" -f $filePath, $chunkCount))
        $oStream.Write($bytesRead, 0, $bytesRead.Count)
        $chunkCount += 1

    }
    
    $oStream.close()
}