<script>
  import "smelte/src/tailwind.css" ;
  import { TextField } from "smelte";

  export let rows = 10;
  export let value = '';

</script>

<TextField label="Code" bind:value={value} {rows} textarea outlined />
