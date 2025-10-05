import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  if (authService.isAuthenticated()) {
    // Check for role-based access if specified in route data
    const requiredRole = route.data?.['role'];
    
    if (requiredRole && !authService.hasRole(requiredRole)) {
      router.navigate(['/dashboard']); // Redirect to dashboard if role doesn't match
      return false;
    }
    
    return true;
  }

  // Redirect to login page with return url
  router.navigate(['/login'], { 
    queryParams: { returnUrl: state.url } 
  });
  return false;
};
