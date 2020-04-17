<script>
  import "smelte/src/tailwind.css" ;
  import { onMount } from "svelte";
  import { Button } from "smelte";
  import CodeWindow from "./CodeWindow.svelte";
  import NomadJobList from "./NomadJobList.svelte";
  import NomadJob from "./NomadJob.svelte";
  import JobDispatcher from "./JobDispatcher.svelte";
  import ArtifactList from "./ArtifactList.svelte";

  export let nomadBaseUrl = 'http://localhost:4646'
  let selectedJob = null;
  let jobDispatcher;
  let dispatchInProgress;
  let code = '';
  let loc;
  let jobSupportsArtifacts;
  let jobIsPythonDispatcher;
  let artifacts;

  function doDispatch() {
    jobDispatcher.dispatch(code, artifacts);
  }
</script>

<main>
  <h1>Nomad Python Dispatcher</h1>
  <NomadJobList bind:selectedJob={selectedJob} {nomadBaseUrl}/>

  {#if selectedJob}
    <NomadJob {nomadBaseUrl} jobName={selectedJob} bind:supportsArtifacts={jobSupportsArtifacts} bind:isPythonDispatcher={jobIsPythonDispatcher}/>
    {#if !jobIsPythonDispatcher}
    <h6 class="text-error-500">Selected job is not a Python Dispatcher</h6>
    {:else}
    {#if jobSupportsArtifacts}
    <ArtifactList bind:artifacts={artifacts} />  
    {/if}
    <CodeWindow bind:value={code} bind:loc={loc} rows=10/>
    <Button on:click="{doDispatch}" disabled={!loc || dispatchInProgress || !jobIsPythonDispatcher}>Submit Code</Button>
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
