export default function HomePage() {
  return (
    <main className="min-h-screen flex items-center justify-center p-8">
      <div className="max-w-2xl text-center space-y-4">
        <h1 className="text-4xl font-semibold">VibecoSwaga</h1>
        <p className="text-gray-500">
          Скелет проекта собран. Каждый разработчик работает в своём слайсе.
        </p>
        <p className="text-sm text-gray-400">
          API health: <a className="underline" href="/api/health">/api/health</a>
          {' · '}
          OpenAPI: <a className="underline" href="/api/v1/openapi.json">/api/v1/openapi.json</a>
        </p>
      </div>
    </main>
  );
}
