import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule, AbstractControl } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterModule],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss'
})
export class RegisterComponent implements OnInit {
  registerForm!: FormGroup;
  isLoading = false;
  registerError = '';
  showPassword = false;
  showConfirmPassword = false;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.initForm();
  }

  private initForm(): void {
    this.registerForm = this.fb.group({
      name: ['', [Validators.required, Validators.minLength(2)]],
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(8)]],
      password_confirmation: ['', [Validators.required]],
      role: ['', [Validators.required]],
      acceptTerms: [false, [Validators.requiredTrue]]
    }, {
      validators: this.passwordMatchValidator
    });
  }

  // Validador personalizado para verificar que las contraseñas coincidan
  private passwordMatchValidator(control: AbstractControl): {[key: string]: any} | null {
    const password = control.get('password');
    const confirmPassword = control.get('password_confirmation');
    
    if (password && confirmPassword && password.value !== confirmPassword.value) {
      return { 'passwordMismatch': true };
    }
    return null;
  }

  togglePassword(): void {
    this.showPassword = !this.showPassword;
  }

  toggleConfirmPassword(): void {
    this.showConfirmPassword = !this.showConfirmPassword;
  }

  onSubmit(): void {
    if (this.registerForm.valid) {
      this.isLoading = true;
      this.registerError = '';

      const formData = this.registerForm.value;
      // Remover acceptTerms ya que no es necesario enviar al servidor
      delete formData.acceptTerms;

      this.authService.register(formData).subscribe({
        next: (response: any) => {
          this.isLoading = false;
          // Redirigir al dashboard después del registro exitoso
          this.router.navigate(['/dashboard']);
        },
        error: (error: any) => {
          this.isLoading = false;
          if (error.error?.errors) {
            // Si hay errores específicos de validación del servidor
            const errors = error.error.errors;
            let errorMessages = [];
            
            for (const field in errors) {
              if (errors[field]) {
                errorMessages.push(...errors[field]);
              }
            }
            
            this.registerError = errorMessages.join(', ');
          } else {
            this.registerError = error.error?.message || 'Error al crear la cuenta. Por favor, intenta de nuevo.';
          }
        }
      });
    } else {
      // Marcar todos los campos como tocados para mostrar errores
      Object.keys(this.registerForm.controls).forEach(key => {
        this.registerForm.get(key)?.markAsTouched();
      });
    }
  }
}
