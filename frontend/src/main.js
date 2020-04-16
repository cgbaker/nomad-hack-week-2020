import App from './App.svelte';

const app = new App({
	target: document.body,
	props: {
      nomadBaseUrl: 'http://nomad.service.thenest:4646'
    }
});

export default app;
