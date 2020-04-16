<script>
  import "smelte/src/tailwind.css" ;
  import { onMount } from "svelte";
  import { Button } from "smelte";
  import CodeWindow from "./CodeWindow.svelte";
  import NomadJobList from "./NomadJobList.svelte";
  import JobDispatcher from "./JobDispatcher.svelte";
  export let nomadBaseUrl = 'http://localhost:4646'
  let selectedJob;
  let jobDispatcher;
  let dispatchInProgress;
  let code = '';
  $: loc = code.trim().length > 0 ? code.split(/\r\n|\r|\n/).length : 0;

  function doDispatch() {
    jobDispatcher.dispatch(code);
  }
</script>

<main>
  <h1>Nomad Python Dispatcher</h1>
  <NomadJobList bind:selectedJob={selectedJob} {nomadBaseUrl}/>

  {#if selectedJob != ""}
    <small>{loc} lines of code</small>
    <CodeWindow bind:value={code} rows=10/>

    <Button on:click="{doDispatch}" disabled={!loc || dispatchInProgress}>Submit Code</Button>

    <JobDispatcher bind:nomadBaseUrl={nomadBaseUrl} bind:targetJob={selectedJob} bind:this={jobDispatcher} bind:inProgress={dispatchInProgress}/>
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
