[CmdletBinding()]
param(
  [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
  [string]$OutputFile = 'QUESTION_TO_CODE_INDEX.md'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryPath = [IO.Path]::GetFullPath($RepositoryRoot)
$outputPath = Join-Path $repositoryPath $OutputFile

$trackSpecifications = @(
  [pscustomobject]@{
    Id = 'sv-basics'
    Label = 'SV Basics'
    Sections = @(
      [pscustomobject]@{ Label = 'Codes'; Root = 'SV Basics\Codes'; Kind = 'Code' }
    )
  },
  [pscustomobject]@{
    Id = 'sv-assertions'
    Label = 'SV Assertions'
    Sections = @(
      [pscustomobject]@{ Label = 'Codes'; Root = 'SV Assertions\Codes'; Kind = 'Code' },
      [pscustomobject]@{ Label = 'Projects'; Root = 'SV Assertions\Projects'; Kind = 'Project' }
    )
  },
  [pscustomobject]@{
    Id = 'sv-functional-coverage'
    Label = 'SV Functional Coverage'
    Sections = @(
      [pscustomobject]@{ Label = 'Codes'; Root = 'SV Functional Coverage\Codes'; Kind = 'Code' },
      [pscustomobject]@{ Label = 'Projects'; Root = 'SV Functional Coverage\Projects'; Kind = 'Project' }
    )
  }
)

function Convert-ToLinkPath {
  param([Parameter(Mandatory)][string]$Path)

  $absolute = [IO.Path]::GetFullPath($Path)
  $relative = [IO.Path]::GetRelativePath($repositoryPath, $absolute)
  (($relative -split '[\\/]') | ForEach-Object { [Uri]::EscapeDataString($_) }) -join '/'
}

function Convert-ToGitHubSlugBase {
  param([Parameter(Mandatory)][string]$Heading)

  $slug = $Heading
  $slug = [regex]::Replace($slug, '!\[([^\]]*)\]\([^)]*\)', '$1')
  $slug = [regex]::Replace($slug, '\[([^\]]+)\]\([^)]*\)', '$1')
  $slug = [regex]::Replace($slug, '<[^>]+>', '')
  $slug = $slug -replace '[`*_~]', ''
  $slug = $slug.ToLowerInvariant().Trim()
  $slug = [regex]::Replace($slug, '[^\p{L}\p{M}\p{Nd}\p{Pc}\-\s]', '')
  $slug = [regex]::Replace($slug, '\s', '-')
  $slug.Trim('-')
}

function Convert-ToTableText {
  param([Parameter(Mandatory)][string]$Text)

  ($Text -replace '\|', '\|' -replace "`r?`n", ' ').Trim()
}

function Get-QuestionTokens {
  param([Parameter(Mandatory)][string]$Text)

  $stopWords = @(
    'the','a','an','is','it','this','that','i','am','are','to','of','in','for',
    'and','or','be','do','does','did','why','what','how','can','should','with',
    'here','there','its','my','me','we','use','using','used','as','on','at','if',
    'when','then','also','so','not','have','has','from','into','was','were'
  )

  @(
    ([regex]::Matches($Text.ToLowerInvariant(), '[a-z0-9_$>-]+') |
      ForEach-Object Value) |
      Where-Object { $_.Length -gt 1 -and $_ -notin $stopWords } |
      Select-Object -Unique
  )
}

function Get-QuestionSimilarity {
  param(
    [Parameter(Mandatory)][string]$Left,
    [Parameter(Mandatory)][string]$Right
  )

  $leftTokens = @(Get-QuestionTokens $Left)
  $rightTokens = @(Get-QuestionTokens $Right)
  if ($leftTokens.Count -eq 0 -or $rightTokens.Count -eq 0) { return 0.0 }

  $intersection = @($leftTokens | Where-Object { $_ -in $rightTokens }).Count
  $intersection / [Math]::Min($leftTokens.Count, $rightTokens.Count)
}

function Get-SourceQuestionLines {
  param([Parameter(Mandatory)][IO.FileInfo[]]$SourceFiles)

  $questions = @()

  foreach ($sourceFile in $SourceFiles) {
    $insideBlockComment = $false
    $lineNumber = 0

    foreach ($line in (Get-Content -LiteralPath $sourceFile.FullName)) {
      $lineNumber++
      $commentText = $null

      if ($insideBlockComment) {
        $commentText = $line
        if ($line -match '\*/') { $insideBlockComment = $false }
      }
      elseif ($line -match '//') {
        $commentText = $line.Substring($line.IndexOf('//') + 2)
      }
      elseif ($line -match '/\*') {
        $commentText = $line.Substring($line.IndexOf('/*') + 2)
        if ($line -notmatch '\*/') { $insideBlockComment = $true }
      }

      if ($null -eq $commentText) { continue }

      $looksLikeQuestion =
        $commentText -match '(?i)\b(why|what|how|can\s+i|should|does|do\s+i|meaning|tell\s+me|wanna\s+know|any\s+values|to\s+be\s+decided)\b' -or
        $commentText.Trim() -match '\?\s*["''`*_]*\s*$'

      if (-not $looksLikeQuestion) { continue }

      $questions += [pscustomobject]@{
        File = $sourceFile
        Line = $lineNumber
        Text = $commentText.Trim()
      }
    }
  }

  $questions
}

function Get-ReadmeQuestionHeadings {
  param([Parameter(Mandatory)][IO.FileInfo]$Readme)

  $lines = Get-Content -LiteralPath $Readme.FullName
  $slugCounts = @{}
  $questions = @()

  for ($lineIndex = 0; $lineIndex -lt $lines.Count; $lineIndex++) {
    $line = $lines[$lineIndex]
    if ($line -notmatch '^(#{1,6})\s+(.+?)\s*#*\s*$') { continue }

    $level = $Matches[1].Length
    $heading = $Matches[2].Trim()
    $baseSlug = Convert-ToGitHubSlugBase $heading

    if ($slugCounts.ContainsKey($baseSlug)) {
      $slugCounts[$baseSlug]++
      $slug = "$baseSlug-$($slugCounts[$baseSlug])"
    }
    else {
      $slugCounts[$baseSlug] = 0
      $slug = $baseSlug
    }

    if ($heading -notmatch '\?') { continue }

    $answerLines = @()
    for ($answerIndex = $lineIndex + 1; $answerIndex -lt $lines.Count; $answerIndex++) {
      if ($lines[$answerIndex] -match '^#{1,6}\s+') { break }
      $answerLines += $lines[$answerIndex]
    }

    $plainAnswer = (($answerLines -join ' ') -replace '[`#|>*_~-]', '' -replace '\s+', ' ').Trim()
    if ($plainAnswer.Length -lt 45) {
      throw "Question heading has no substantive answer: $($Readme.FullName):$($lineIndex + 1) — $heading"
    }

    $questions += [pscustomobject]@{
      Text = $heading
      Level = $level
      Line = $lineIndex + 1
      Slug = $slug
      AnswerCharacters = $plainAnswer.Length
    }
  }

  $questions
}

function Get-EntryRecord {
  param(
    [Parameter(Mandatory)][IO.DirectoryInfo]$Directory,
    [Parameter(Mandatory)][string]$Kind
  )

  $readmePath = Join-Path $Directory.FullName 'README.md'
  if (-not (Test-Path -LiteralPath $readmePath)) {
    throw "Missing README: $readmePath"
  }

  $readme = Get-Item -LiteralPath $readmePath
  $readmeLines = Get-Content -LiteralPath $readme.FullName
  $h1 = $readmeLines | Where-Object { $_ -match '^#\s+' } | Select-Object -First 1
  if (-not $h1) { throw "Missing H1: $readmePath" }

  $sourceFiles = @(Get-ChildItem -LiteralPath $Directory.FullName -Filter '*.sv' -File | Sort-Object Name)
  $sourceQuestions = @(Get-SourceQuestionLines $sourceFiles)
  $readmeQuestions = @(Get-ReadmeQuestionHeadings $readme)

  if ($sourceQuestions.Count -gt 0 -and $readmeQuestions.Count -eq 0) {
    throw "Source questions have no README Q&A destination: $($Directory.FullName)"
  }

  [pscustomobject]@{
    Kind = $Kind
    Directory = $Directory
    Number = if ($Directory.Name -match '^(\d+)') { $Matches[1] } else { $Directory.Name }
    Topic = ($h1 -replace '^#\s+', '').Trim()
    Readme = $readme
    ReadmeLink = Convert-ToLinkPath $readme.FullName
    SourceFiles = $sourceFiles
    SourceQuestions = $sourceQuestions
    Questions = $readmeQuestions
  }
}

$trackRecords = @()
$totalEntries = 0
$totalQuestions = 0
$totalSourceQuestions = 0

foreach ($track in $trackSpecifications) {
  $sectionRecords = @()
  foreach ($section in $track.Sections) {
    $sectionPath = Join-Path $repositoryPath $section.Root
    if (-not (Test-Path -LiteralPath $sectionPath)) { continue }

    $entries = @(
      Get-ChildItem -LiteralPath $sectionPath -Directory |
        Sort-Object Name |
        ForEach-Object { Get-EntryRecord -Directory $_ -Kind $section.Kind }
    )

    $sectionRecords += [pscustomobject]@{
      Label = $section.Label
      Kind = $section.Kind
      Entries = $entries
    }

    $totalEntries += $entries.Count
    $totalQuestions += ($entries | ForEach-Object Questions | Measure-Object).Count
    $totalSourceQuestions += ($entries | ForEach-Object SourceQuestions | Measure-Object).Count
  }

  $trackRecords += [pscustomobject]@{
    Id = $track.Id
    Label = $track.Label
    Sections = $sectionRecords
    EntryCount = ($sectionRecords | ForEach-Object Entries | Measure-Object).Count
    QuestionCount = ($sectionRecords | ForEach-Object Entries | ForEach-Object Questions | Measure-Object).Count
    SourceQuestionCount = ($sectionRecords | ForEach-Object Entries | ForEach-Object SourceQuestions | Measure-Object).Count
  }
}

$output = [Collections.Generic.List[string]]::new()
$output.Add('# SystemVerilog Question-to-Code Index')
$output.Add('')
$output.Add('> One compact map from every recorded question to the code or project where it arose and the README discussion that answers it.')
$output.Add('')
$output.Add('[SV Basics](#sv-basics) · [SV Assertions](#sv-assertions) · [SV Functional Coverage](#sv-functional-coverage) · [Repository home](README.md)')
$output.Add('')
$output.Add('## How to use this page')
$output.Add('')
$output.Add('- Click a **question** to jump to its answered discussion in the matching README.')
$output.Add('- Click **asked in code** to open the exact source line when the question was written inside an `.sv` file.')
$output.Add('- Click a code/project number or source filename to open the complete lesson.')
$output.Add('- Entries with no explicit question remain listed so every code is visible and the audit boundary is obvious.')
$output.Add('')
$output.Add('## Review audit')
$output.Add('')
$output.Add("This generated index reviewed **$totalEntries code/project folders**, found **$totalQuestions answered question headings**, and linked **$totalSourceQuestions question-like source comments**. Generation stops with an error if a folder lacks a README, a question heading lacks substantive answer text, or a folder containing a source question has no README question destination.")
$output.Add('')
$output.Add('| Track | Codes/projects reviewed | Answered questions | Questions written in source |')
$output.Add('|---|---:|---:|---:|')
foreach ($track in $trackRecords) {
  $output.Add("| [$($track.Label)](#$($track.Id)) | $($track.EntryCount) | $($track.QuestionCount) | $($track.SourceQuestionCount) |")
}

foreach ($track in $trackRecords) {
  $output.Add('')
  $output.Add("## $($track.Label)")

  foreach ($section in $track.Sections) {
    if ($track.Sections.Count -gt 1) {
      $output.Add('')
      $output.Add("### $($section.Label)")
    }

    $output.Add('')
    $output.Add('| Code | Topic | Question → answered discussion | Source |')
    $output.Add('|---:|---|---|---|')

    foreach ($entry in $section.Entries) {
      $codeLabel = if ($entry.Kind -eq 'Project') { "Project $($entry.Number)" } else { $entry.Number }
      $codeCell = "[$codeLabel]($($entry.ReadmeLink))"
      $topicCell = Convert-ToTableText $entry.Topic

      if ($entry.Questions.Count -eq 0) {
        $questionCell = "No explicit question recorded; [open the reviewed discussion]($($entry.ReadmeLink))."
      }
      else {
        $questionLinks = @()
        $questionOrdinal = 0
        foreach ($question in $entry.Questions) {
          $questionOrdinal++
          $questionText = Convert-ToTableText $question.Text
          $questionLink = "$($entry.ReadmeLink)#$($question.Slug)"
          $questionItem = "$questionOrdinal. [$questionText]($questionLink)"

          $bestSource = $null
          $bestScore = 0.0
          foreach ($sourceQuestion in $entry.SourceQuestions) {
            $score = Get-QuestionSimilarity -Left $question.Text -Right $sourceQuestion.Text
            if ($score -gt $bestScore) { $bestScore = $score; $bestSource = $sourceQuestion }
          }

          if ($bestSource -and $bestScore -ge 0.20) {
            $sourceLink = "$(Convert-ToLinkPath $bestSource.File.FullName)#L$($bestSource.Line)"
            $questionItem += " · [asked in code]($sourceLink)"
          }

          $questionLinks += $questionItem
        }
        $questionCell = $questionLinks -join '<br>'
      }

      $sourceLinks = @($entry.SourceFiles | ForEach-Object {
        "[$($_.Name)]($(Convert-ToLinkPath $_.FullName))"
      })

      if ($entry.SourceQuestions.Count -gt 0) {
        $askedLinks = @($entry.SourceQuestions | ForEach-Object {
          "[$($_.File.Name):L$($_.Line)]($(Convert-ToLinkPath $_.File.FullName)#L$($_.Line))"
        })
        $sourceLinks += "Asked lines: $($askedLinks -join ', ')"
      }

      $sourceCell = if ($sourceLinks.Count -gt 0) { $sourceLinks -join '<br>' } else { 'README-only lesson' }
      $output.Add("| $codeCell | $topicCell | $questionCell | $sourceCell |")
    }
  }
}

$output.Add('')
$output.Add('## Maintenance')
$output.Add('')
$output.Add('After adding or changing a lesson question, regenerate this page from the repository root:')
$output.Add('')
$output.Add('```powershell')
$output.Add('.\scripts\build-question-to-code-index.ps1')
$output.Add('```')
$output.Add('')
$output.Add('The script performs the same README, answer-body, and source-question checks before replacing this index.')

$utf8NoBom = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText($outputPath, (($output -join "`n") + "`n"), $utf8NoBom)

Write-Output "Generated $outputPath"
Write-Output "Entries: $totalEntries"
Write-Output "Answered questions: $totalQuestions"
Write-Output "Source question lines: $totalSourceQuestions"
