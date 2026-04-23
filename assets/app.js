// Import Bootstrap JS (requires Popper.js which is bundled)
import 'bootstrap';

// Import Alpine.js
import Alpine from 'alpinejs';
import Collapse from '@alpinejs/collapse';

Alpine.plugin(Collapse);

// Start Alpine
window.Alpine = Alpine;
Alpine.start();
