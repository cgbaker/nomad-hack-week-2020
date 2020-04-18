<script>
  import "smelte/src/tailwind.css" ;
  import { Select } from "smelte";
  import { onMount } from "svelte";
  import ProgressLinear from 'smelte/src/components/ProgressLinear';

  export let nomadBaseUrl;

  let parametrizedJobs;
  let error;
  let loading = false;

  let jobUrl = nomadBaseUrl + '/v1/jobs';
  onMount(async () => {
    loading = true;
    await fetch(jobUrl , {
        mode: 'cors'
      })
      .then(r => r.json())
      .then(data => {
        parametrizedJobs = data.filter(j => j.ParameterizedJob).map(j => 
          ({value: j.Name, text: j.Name})
        );
      })
      .catch(err => {
        console.log("error: " + err);
        error = err;
      })
      .finally( () => {
        loading = false;
      })
  })

  export let selectedJob = '';
</script>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

{#if loading}
<div class="p-1 m-1 border-2"> 
  <p class="mb-1 mt-1"><i>loading nomad jobs...</i></p>
  <ProgressLinear />
</div>
{:else}
  {#if error}
    <div class="alert">
      Error fetching jobs: {error}
    </div>
  {:else}
    <Select bind:value={selectedJob} outlined label="Dispatch target" items={parametrizedJobs} />
  {/if}
{/if}

<style>
  .alert {
    background-color: red;
    text-align: left;
  }
</style>
