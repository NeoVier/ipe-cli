const esbuild = require('esbuild')
const ElmPlugin = require('esbuild-plugin-elm')

esbuild.build({
    entryPoints: ['src/index.ts'],
    bundle: true,
    outdir: 'dist',
    watch: process.argv.includes('--watch'),
    plugins: [ElmPlugin()]
}).catch(_e => process.exit(1))
