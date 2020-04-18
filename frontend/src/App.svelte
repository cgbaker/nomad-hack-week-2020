<script>
  import "smelte/src/tailwind.css" ;
  import { onMount } from "svelte";
  import { Button } from "smelte";
  import CodeWindow from "./CodeWindow.svelte";
  import NomadJobList from "./NomadJobList.svelte";
  import NomadJob from "./NomadJob.svelte";
  import JobDispatcher from "./JobDispatcher.svelte";
  import ArtifactList from "./ArtifactList.svelte";

  const nomadBaseUrl = 'NOMAD_ADDR';

  let selectedJob = null;
  let jobDispatcher;
  let dispatchInProgress;
  let code = '';
  let loc;
  let supportsArtifacts;
  let isPythonDispatcher;
  let artifacts;

  function doDispatch() {
    jobDispatcher.dispatch(code, artifacts);
  }
</script>

<main>
  <h1>Nomad Python Dispatcher</h1>
  <h6 class="pb-1 mb-1">{nomadBaseUrl}</h6>
  <NomadJobList bind:selectedJob {nomadBaseUrl}/>

  {#if selectedJob}
    <NomadJob {nomadBaseUrl} jobName={selectedJob} bind:supportsArtifacts bind:isPythonDispatcher/>
    {#if !isPythonDispatcher}
    <h6 class="text-error-500">Selected job is not a Python Dispatcher</h6>
    {:else}
    {#if supportsArtifacts}
    <ArtifactList bind:artifacts/>  
    {/if}
    <CodeWindow bind:disabled={dispatchInProgress} bind:value={code} bind:loc rows=10/>
    <Button on:click="{doDispatch}" disabled={!loc || dispatchInProgress || !isPythonDispatcher}>Submit Code</Button>
    <JobDispatcher {nomadBaseUrl} bind:targetJob={selectedJob} bind:this={jobDispatcher} bind:inProgress={dispatchInProgress}/>
    {/if}
  {/if}
</main>

<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	h1 {
		color: #25ba81;
		font-size: 4em;
		font-weight: 200;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>
