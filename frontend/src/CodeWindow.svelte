<script>
  import "smelte/src/tailwind.css" ;
  import { TextField } from "smelte";

  export let rows = 10;
  export let value = '';
  export let loc = 0;
  $: loc = value.trim().length > 0 ? value.split(/\r\n|\r|\n/).length : 0;
  $: locUnit = loc == 1 ? "line" : "lines";

</script>

<TextField label="{loc > 0 ? loc + " " + locUnit + " of beautiful Python" : "Python code goes here"}" bind:value={value} {rows} textarea outlined />
