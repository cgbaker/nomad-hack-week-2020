<script>
  import { onMount, afterUpdate  } from "svelte";

  export let nomadBaseUrl;
  export let jobName;

  export let job = null;
  export let supportsArtifacts = null;
  export let isPythonDispatcher = null;
  
  let oldJobName = null

  async function getJob() {
    if (oldJobName == jobName) {
      return;
    }
    oldJobName = jobName;
    let jobUrl = nomadBaseUrl + '/v1/job/' + jobName;
    await fetch(jobUrl , {
      mode: 'cors'
    })
    .then(r => r.json())
    .then(data => {
      job = data;
      supportsArtifacts = job.Meta && job.Meta['supports-artifacts'] == "true";
      isPythonDispatcher = job.Meta && job.Meta['python-dispatcher'] == "true";
    });
  }

  onMount(getJob)
  afterUpdate(getJob)
</script>
