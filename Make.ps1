$REPO = "steffenblake/webhook-hugo"
$VER = "1.0.14.2"

$PUBLISH = $TRUE

$ARCHLIST = @{
  amd64 = "amd64"
}

if ($PUBLISH) {
  $ARCHLIST = @{
    arm = "arm/v7";
    arm64 = "arm64"; 
    amd64 = "amd64" 
  }
}

$ManifestLatest = $Repo + ":latest"
$ManifestVer = $Repo + ":" + $VER

docker manifest rm $ManifestLatest
docker manifest rm $ManifestVer

ForEach ($ARCH in $ARCHLIST.keys) {
  $ArchRepo = $Repo + ":linux-" + $ARCH
  $LatestRepo = $ArchRepo + "-latest"
  $VerRepo = $ArchRepo + "-" + $VER
  if ($PUBLISH) {
    Write-Output "Pushing to $LatestRepo / $VerRepo"
    docker buildx build . --platform linux/$ARCH -t $LatestRepo -t $VerRepo --push
    Write-Output "Composing to Manifests $ManifestLatest / $ManifestVer"
    docker manifest create $ManifestLatest --amend $LatestRepo
    docker manifest create $ManifestVer --amend $VerRepo
  } else {
    docker buildx build . --platform linux/$ARCH -t $LatestRepo -t $VerRepo
  }
}

if ($PUBLISH) {
  Write-Output "Publishing to Manifests $ManifestLatest / $ManifestVer"

  docker manifest push --purge $ManifestLatest
  docker manifest push --purge $ManifestVer
}