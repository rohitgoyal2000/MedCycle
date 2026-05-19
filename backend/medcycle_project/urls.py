from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse

FRONTEND = settings.BASE_DIR.parent / 'frontend'

def landing(request):
    citizen  = (FRONTEND / 'index.html').read_text(encoding='utf-8')
    dashboard = FRONTEND / 'dashboard.html'
    pharmacy  = FRONTEND / 'pharmacy.html'
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>MedCycle</title>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&display=swap" rel="stylesheet"/>
  <style>
    *{{font-family:'Plus Jakarta Sans',sans-serif;box-sizing:border-box;margin:0;padding:0}}
    body{{background:linear-gradient(135deg,#dbeafe 0%,#ede9fe 50%,#e0f2fe 100%);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px}}
    .card{{background:rgba(255,255,255,0.88);backdrop-filter:blur(20px);border-radius:24px;padding:40px;max-width:480px;width:100%;box-shadow:0 12px 48px rgba(37,99,235,0.14);border:1px solid rgba(255,255,255,0.7)}}
    .logo{{width:64px;height:64px;background:linear-gradient(135deg,#2563EB,#7C3AED);border-radius:20px;display:flex;align-items:center;justify-content:center;font-size:28px;font-weight:800;color:white;margin:0 auto 20px;box-shadow:0 8px 24px rgba(37,99,235,0.35)}}
    h1{{text-align:center;font-size:26px;font-weight:800;color:#0A0F1E;margin-bottom:6px}}
    .sub{{text-align:center;font-size:13px;color:#64748b;margin-bottom:32px}}
    .btn{{display:block;width:100%;padding:14px;border-radius:14px;text-decoration:none;font-weight:700;font-size:14px;text-align:center;margin-bottom:12px;transition:all .2s;position:relative;overflow:hidden}}
    .btn-1{{background:linear-gradient(135deg,#2563EB,#7C3AED);color:white;box-shadow:0 4px 16px rgba(37,99,235,0.30)}}
    .btn-1:hover{{transform:translateY(-1px);box-shadow:0 8px 24px rgba(37,99,235,0.40)}}
    .btn-2{{background:linear-gradient(135deg,#059669,#0EA5E9);color:white;box-shadow:0 4px 16px rgba(5,150,105,0.30)}}
    .btn-2:hover{{transform:translateY(-1px);box-shadow:0 8px 24px rgba(5,150,105,0.40)}}
    .btn-3{{background:linear-gradient(135deg,#0f172a,#1e293b);color:white;box-shadow:0 4px 16px rgba(15,23,42,0.30)}}
    .btn-3:hover{{transform:translateY(-1px);box-shadow:0 8px 24px rgba(15,23,42,0.40)}}
    .divider{{border:none;border-top:1px solid #e2e8f0;margin:20px 0}}
    .api-link{{text-align:center;font-size:12px;color:#94a3b8}}
    .api-link a{{color:#2563EB;font-weight:600;text-decoration:none}}
    .badge{{display:inline-flex;align-items:center;gap:4px;background:rgba(16,185,129,0.10);color:#059669;border:1px solid rgba(16,185,129,0.25);border-radius:20px;padding:4px 10px;font-size:11px;font-weight:700;margin-bottom:24px}}
    .center{{display:flex;justify-content:center}}
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">M</div>
    <h1>MedCycle</h1>
    <p class="sub">Smart AMR Disposal Ecosystem</p>
    <div class="center"><div class="badge">&#x25CF; Server running on localhost:8000</div></div>
    <a href="/citizen" class="btn btn-1">💊 Citizen App</a>
    <a href="/pharmacy" class="btn btn-2">🏪 Pharmacy Portal</a>
    <a href="/dashboard" class="btn btn-3">📊 Government Dashboard</a>
    <hr class="divider"/>
    <div class="api-link">
      Admin panel: <a href="/admin/">/admin/</a> &nbsp;·&nbsp;
      API root: <a href="/api/v1/">/api/v1/</a>
    </div>
  </div>
</body>
</html>"""
    return HttpResponse(html)


def serve_frontend(filename):
    def view(request):
        path = FRONTEND / filename
        return HttpResponse(path.read_text(encoding='utf-8'), content_type='text/html')
    return view


urlpatterns = [
    path('', landing, name='landing'),
    path('citizen', serve_frontend('index.html'), name='citizen'),
    path('dashboard', serve_frontend('dashboard.html'), name='dashboard'),
    path('pharmacy', serve_frontend('pharmacy.html'), name='pharmacy'),
    path('admin/', admin.site.urls),
    path('api/v1/', include('core.urls')),
    path('api/v1/rewards/', include('rewards.urls')),
    path('api/v1/analytics/', include('analytics.urls')),
    path('api/v1/chatbot/', include('chatbot.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
