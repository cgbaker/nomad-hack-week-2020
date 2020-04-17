<script> 
  import "smelte/src/tailwind.css" ;
  import { onDestroy } from 'svelte';
  import { TextField } from "smelte";
  import { Button } from "smelte";
  import { Icon } from "smelte";
  import { Chip } from "smelte";

  export let artifacts = []; 

  let curArtifact;
  function addArtifact() {
    if ( curArtifact.trim().length ) {
      artifacts = [...artifacts, curArtifact];
      curArtifact = '';
      console.log("artifacts: " + artifacts);
    }
  }
 
  onDestroy(() => {
    artifacts = [];
  });
</script>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

<div class="relative w-full border-b">
  <div>
    <TextField class="w-auto inline-block" bind:value={curArtifact} label="Artifact URL" outlined />
  </div>
  <div class="static">
  <Button small on:click={addArtifact}>Add</Button>
  {#each artifacts as artifact, index}
    <Chip>{artifact}</Chip>
  {/each}
  </div>
</div>
