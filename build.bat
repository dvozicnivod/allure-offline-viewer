# save as allure_offline_viewer.py
import sys
import os
import tempfile
import zipfile
import http.server
import socketserver
import webbrowser
import argparse
import atexit
import shutil
from pathlib import Path
try:
    import tkinter as tk
    from tkinter import filedialog
except ImportError:
    tk = None

# Configuration
REPO_TEMP = Path(__file__).parent / "temp"
DEFAULT_PORT = 0  # Let OS choose port

class AllureViewer:
    def __init__(self):
        self.httpd = None
        self.cleanup_paths = []
        atexit.register(self.cleanup)
        
    def cleanup(self):
        """Clean up temporary resources"""
        for path in self.cleanup_paths:
            if Path(path).exists():
                shutil.rmtree(path, ignore_errors=True)
        if self.httpd:
            self.httpd.shutdown()

    def validate_report(self, path):
        """Check if directory contains valid Allure report"""
        return (Path(path) / "index.html").exists()

    def extract_zip(self, zip_path):
        """Extract report zip to repository temp directory"""
        REPO_TEMP.mkdir(exist_ok=True)
        extract_path = REPO_TEMP / Path(zip_path).stem
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_path)
        self.cleanup_paths.append(extract_path)
        return extract_path

    def start_server(self, report_path, port=DEFAULT_PORT):
        """Start HTTP server with cleanup handling"""
        os.chdir(str(report_path))
        handler = http.server.SimpleHTTPRequestHandler
        self.httpd = socketserver.TCPServer(("", port), handler)
        return self.httpd.server_address[1]

    def open_report(self, path):
        """Main execution flow"""
        try:
            path = Path(path).resolve()
            
            # Handle ZIP files
            if path.suffix.lower() == ".zip":
                if not zipfile.is_zipfile(path):
                    raise ValueError("Invalid ZIP file")
                path = self.extract_zip(path)

            # Validate Allure report
            if not self.validate_report(path):
                raise ValueError("No valid Allure report found")

            # Start server
            port = self.start_server(path)
            url = f"http://localhost:{port}/index.html"
            
            # Open browser
            webbrowser.open(url)
            print(f"Serving report at {url}")
            
            # Keep server running
            self.httpd.serve_forever()
            
        except Exception as e:
            self.cleanup()
            print(f"Error: {str(e)}")
            sys.exit(1)

def gui_main():
    """Graphical file selection mode"""
    root = tk.Tk()
    root.withdraw()
    path = filedialog.askopenfilename(
        title="Select Allure Report (folder or ZIP)",
        filetypes=[("Allure Reports", "*.zip"), ("Allure Folder", "")]
    )
    if path:
        AllureViewer().open_report(path)

def cli_main():
    """Command line mode"""
    parser = argparse.ArgumentParser()
    parser.add_argument("path", nargs="?", help="Path to report folder/ZIP")
    args = parser.parse_args()
    
    if args.path:
        AllureViewer().open_report(args.path)
    else:
        print("Please provide path or run without arguments for GUI mode")

if __name__ == "__main__":
    if len(sys.argv) > 1 or not tk:
        cli_main()
    else:
        gui_main()