import { execSync } from 'node:child_process'
import { existsSync, readFileSync, writeFileSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const raiz = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const bump = process.argv[2]
const sinGit = process.argv.includes('--no-git')

if (!['major', 'minor', 'patch'].includes(bump ?? '')) {
  console.error('Uso: node scripts/bump.js <major|minor|patch> [--no-git]')
  process.exit(1)
}

const pubspecRuta = path.join(raiz, 'pubspec.yaml')
const pubspec = readFileSync(pubspecRuta, 'utf8')
const coincidencia = pubspec.match(/^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$/m)

if (!coincidencia) {
  console.error('No se encontró una línea "version: X.Y.Z+N" en pubspec.yaml')
  process.exit(1)
}

const mayor = Number(coincidencia[1])
const menor = Number(coincidencia[2])
const parche = Number(coincidencia[3])
const build = Number(coincidencia[4])

const siguienteNombre =
  bump === 'major'
    ? `${mayor + 1}.0.0`
    : bump === 'minor'
      ? `${mayor}.${menor + 1}.0`
      : `${mayor}.${menor}.${parche + 1}`
const siguienteBuild = build + 1

writeFileSync(
  pubspecRuta,
  pubspec.replace(coincidencia[0], `version: ${siguienteNombre}+${siguienteBuild}`),
)
console.log(`pubspec.yaml → ${siguienteNombre}+${siguienteBuild}`)

const paqueteRuta = path.join(raiz, 'package.json')
if (existsSync(paqueteRuta)) {
  const paquete = JSON.parse(readFileSync(paqueteRuta, 'utf8'))
  paquete.version = siguienteNombre
  writeFileSync(paqueteRuta, `${JSON.stringify(paquete, null, 2)}\n`)
  console.log(`package.json → ${siguienteNombre}`)
}

if (!sinGit) {
  const ficheros = ['pubspec.yaml']
  if (existsSync(paqueteRuta)) ficheros.push('package.json')
  execSync(`git add ${ficheros.join(' ')}`, { cwd: raiz })
  execSync(`git commit -m "chore(release): v${siguienteNombre}"`, { cwd: raiz })
  execSync(`git tag -a v${siguienteNombre} -m "v${siguienteNombre}"`, { cwd: raiz })
  console.log(`Commit y tag v${siguienteNombre} creados`)
}
