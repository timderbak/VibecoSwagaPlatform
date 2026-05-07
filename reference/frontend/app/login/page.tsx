export default function LoginPage() {
  return (
    <main className="min-h-screen flex items-center justify-center p-8">
      <div className="max-w-md w-full space-y-6 p-8 border rounded-lg">
        <h1 className="text-2xl font-semibold">Вход</h1>
        <p className="text-gray-500 text-sm">
          Placeholder. Реализуется владельцем слайса <code className="bg-gray-100 px-1">auth</code>.
        </p>
        <form className="space-y-4 opacity-60 pointer-events-none">
          <div>
            <label htmlFor="email" className="block text-sm font-medium">Email</label>
            <input
              id="email"
              type="email"
              className="mt-1 w-full px-3 py-2 border rounded-md"
              disabled
            />
          </div>
          <div>
            <label htmlFor="password" className="block text-sm font-medium">Пароль</label>
            <input
              id="password"
              type="password"
              className="mt-1 w-full px-3 py-2 border rounded-md"
              disabled
            />
          </div>
          <button
            type="submit"
            className="w-full bg-primary-500 text-white py-2 rounded-md hover:bg-primary-600"
            disabled
          >
            Войти
          </button>
        </form>
      </div>
    </main>
  );
}
