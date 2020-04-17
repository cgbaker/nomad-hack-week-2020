<script>
  import { Select } from "smelte";
  import { onMount } from "svelte";

  export let nomadBaseUrl = 'http://localhost:4646';

  let parametrizedJobs;

  let jobUrl = nomadBaseUrl + '/v1/jobs';
  onMount(async () => {
    await fetch(jobUrl , {
        mode: 'cors'
      })
      .then(r => r.json())
      .then(data => {
        parametrizedJobs = data.filter(j => j.ParameterizedJob).map(j => 
          ({value: j.Name, text: j.Name})
        );
      })
  })

  export let selectedJob = '';
</script>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

{#if parametrizedJobs}
<Select bind:value={selectedJob} outlined label="Dispatch target" items={parametrizedJobs} />
{:else}
<p class="loading">loading nomad jobs...</p>
{/if}
