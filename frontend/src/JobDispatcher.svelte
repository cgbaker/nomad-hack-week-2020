<style>
  .top-space {
     margin-top: 1cm;
  }
</style>

<script>
  import ProgressLinear from 'smelte/src/components/ProgressLinear';
  import { TextField } from "smelte";

  import "smelte/src/tailwind.css" ;

  export let inProgress = false;
  export let nomadBaseUrl;
  export let targetJob;

  let dispatchJobId;
  let newJobUrl;
  let allocStatus;
  let lastEvent;
  let allocOutput;

  function clear() {
    dispatchJobId = null;
    newJobUrl = null;
    allocStatus = null;
    lastEvent = null;
    allocOutput = null;
  }

  async function _dispatchJob(body) {
    let dispatchUrl = nomadBaseUrl + "/v1/job/" + targetJob + "/dispatch";
    return fetch(dispatchUrl, {
      mode: 'cors',
      method: 'POST',
      body: JSON.stringify(body),
    }).then(r => r.json())
      .then(resp => {
        dispatchJobId = resp.DispatchedJobID;
        return resp;;
      })
  }

  function _getEvalAlloc(evalId) {
    console.log("getting allocations for " + evalId);
    let url = nomadBaseUrl + "/v1/evaluation/" + evalId + "/allocations";
    return fetch(url, {
      mode: 'cors',
    }).then(r => r.json())
      .then(resp => resp[0])
  }

  function _getLastEvent(alloc) {
    if (alloc.TaskStates && alloc.TaskStates.dispatcher && alloc.TaskStates.dispatcher.Events.length > 0) {
      let events = alloc.TaskStates.dispatcher.Events;
      return events[events.length-1].DisplayMessage;
    }
    return null;
  }

  function _monitorAlloc(alloc) {
    console.log("monitoring allocation " + alloc.ID);
    let url = nomadBaseUrl + "/v1/allocation/" + alloc.ID + "?index=" + alloc.ModifyIndex;
    return fetch(url, {
      mode: 'cors',
    }).then(r => r.json())
      .then(alloc => {
        lastEvent = _getLastEvent(alloc);

        allocStatus = alloc.ClientStatus; 
        if (allocStatus == "complete" || allocStatus == "failed" || allocStatus == "lost") {
          console.log("Allocation is done");
          return new Promise(function(resolve, reject) {
            resolve(alloc);
          });
        }
        console.log("Allocation not complete; recursing");
        return _monitorAlloc(alloc);
      })
  }

  function _monitorEval(evalId, index) {
    console.log("monitoring eval " + evalId);
    let url = nomadBaseUrl + "/v1/evaluation/" + evalId + "?index=" + index;
    return fetch(url, {
      mode: 'cors',
    }).then(r => r.json())
      .then(resp => {
        if (resp.Status == "complete") {
          console.log("Evaluation is complete");
          return new Promise(function(resolve, reject) {
            resolve(evalId);
          });
        }
        console.log("Evaluation not complete; recursing");
        return _monitorEval(evalId, resp.ModifyIndex);
      })
  }

  function _getOutput(alloc) {
    console.log("getting output from " + alloc.ID);
    let type = "stdout";
    if (alloc.ClientStatus == "failed") {
      type = "stderr";
    }
    let url = nomadBaseUrl + "/v1/client/fs/logs/" + alloc.ID + "?task=dispatcher&plain=true&type=" + type;
    return fetch(url, {
      mode: 'cors',
    }).then(r => r.text()) 
  }

  export async function dispatch(code, artifacts) {
    if (inProgress) return;
    clear();
    inProgress = true;
    console.log("starting dispatch")
    let body = {
      Payload: btoa(code),
      Meta: {},
    };
    if (artifacts && artifacts.length) {
      body.Meta.artifacts = artifacts.join(",");
    }
    return await 
        _dispatchJob(body)
        .then(resp => _monitorEval(resp.EvalID, resp.EvalCreateIndex))
        .then(evalId => _getEvalAlloc(evalId))
        .then(alloc => _monitorAlloc(alloc))
        .then(alloc => _getOutput(alloc))
        .then(output => {
            allocOutput = output;
            inProgress = false;
        });
  }
</script>

<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

{#if dispatchJobId}
<p class="top-space">Dispatched Job ID: <a target=_blank href="{
  newJobUrl = nomadBaseUrl + "/ui/jobs/" + dispatchJobId.replace('/', '%2F')
}">{dispatchJobId}</a></p>
{/if}
{#if allocStatus}
<p>Allocation Status: {allocStatus}</p>
{/if}
{#if lastEvent}
<p>Last Task Event: {lastEvent}</p>
{/if}
{#if inProgress}
<ProgressLinear />
{:else if allocOutput}
<TextField textarea disabled label="Output" value={allocOutput} />
{/if}

