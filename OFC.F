      PROGRAM OFC_MODEL
      implicit none
      real*8 critical_value,alpha,red
      real*8 heat,progress
      real*8 entropyShannon,total_energy
      integer L,i,iterations,N_iterations
      integer visited_suma
      character(len=256) :: name_file 
      character(len=256) :: base_path
      parameter (critical_value=1.0d0)
c      parameter (alpha=0.20d0)
      parameter (L=200)
      parameter (N_iterations=6000000)
      dimension red(L,L)
      progress = 0.0d0

      do alpha=0.21d0,0.25d0,0.01d0 

      name_file="results/L_{L}/alpha{alpha:.2f}-{critical_value}"//
     &"-L{L}-N_iterations{N_iterations}-wait_n_iters0-dtypef8.dat"
      write(name_file, '(a,i0,a,f4.2,a,f3.1,a,i0,a,i0,a)') 
     &'results/L_',L,'/alpha',alpha,'-',critical_value,'-L', 
     &L,'-N_iterations', N_iterations,
     &'-wait_n_iters0-dtypef8.dat'

      open(10,file=trim(name_file))
      write(10,'(A)') 'AvalancheSize,NumberOfIterations,' //
     &'TotalEnergy,DissipatedEnergy,EntropyShannon'


      call red_inicial(critical_value,L,red)

c     Bucle principal de N iteraciones      
      do i=1, N_iterations
      call print_progress_bar(progress)

c           Escribir valores en el archivo
      call drive(critical_value,L,red)
      call AvalancheLoop(alpha,
     & critical_value,L,red,visited_suma
     & ,iterations,total_energy,
     & heat)
      call entropy(critical_value,L,red,entropyShannon)



       write(10, '(I0,",",I0,",",F20.8,",",F20.8,",",F20.8)')
     &visited_suma,iterations,total_energy,heat,entropyShannon



      progress = i / real(N_iterations - 1)
      end do

      close(10)

      end do 
      END PROGRAM 



c---------------------------------------------------------------------------
c------------------- RED INICIAL SUBROUTINA --------------------------------
c --------------------------------------------------------------------------
      subroutine red_inicial(critical_value,L,red)
      implicit none
      real*8 critical_value,red
      integer L,i,j
      dimension red(L,L)
      CALL init_random_seed()
      call random_number(red)

      red=(red-minval(red))/(maxval(red)-minval(red))
      red=red*critical_value
      end subroutine red_inicial
c---------------------------------------------------------------------------
c------------------- AÑADIR ENERGÍA SUBROUTINA -----------------------------
c --------------------------------------------------------------------------
      subroutine drive(critical_value,L,red)
      implicit none
      real*8 critical_value,red,value_max
      integer L
      dimension red(L,L)

      value_max=maxval(red)

      if (value_max.LT.critical_value)then
            red=red+(critical_value-value_max)
      end if
      end subroutine drive
c---------------------------------------------------------------------------
c------------------- DINÁMICA OFC SUBROUTINA -------------------------------
c --------------------------------------------------------------------------
      subroutine topple(alpha,critical_value,L,red,
     & iterations,heat,active_zones,visited_suma)
      implicit none
      real*8 critical_value,red,heat 
      real*8 red_dist,releases,alpha
      integer L,i,j,iterations,capacity,active_zones
      integer n,x,y,visited_suma
      logical active,visited
      integer, allocatable :: stack(:, :)
      dimension red(L,L),releases(L,L),visited(L,L)
      
      iterations=0
      heat=0.d0
      visited = .FALSE.
      capacity=L*L
      allocate(stack(2, capacity))


      do
      active_zones=0
      do j=1,L 
            do i=1,L
                  if (red(i,j).GE.critical_value)then
                        active_zones = active_zones + 1
                        stack(1,active_zones) = i
                        stack(2,active_zones) = j     
                  end if
            end do 
      end do

      if (active_zones == 0)then  ! no hay sitios activos
            exit
      end if
      ! Toppling 
      do n=1,active_zones
            x=stack(1,n)
            y=stack(2,n)
            red_dist = red(x,y)
            ! Aplicar a los vecinos (fronteras no periódicas)
            if (y+1 <= L) then
                red(x,y+1) = red(x,y+1) + alpha * red_dist
                visited(x,y+1) = .true.
            end if
            if (x-1 >= 1) then
                red(x-1,y) = red(x-1,y) + alpha * red_dist
                visited(x-1,y) = .true.
            end if
            if (x+1 <= L) then
                red(x+1,y) = red(x+1,y) + alpha * red_dist
                visited(x+1,y) = .true.
            end if
            if (y-1 >= 1) then
                red(x,y-1) = red(x,y-1) + alpha * red_dist
                visited(x,y-1) = .true.
            end if

            releases(x,y) = releases(x,y) + 1.0d0
            heat = heat + (1.0d0 - 4.0d0 * alpha) * red_dist
            red(x,y) = 0.0d0
      end do
            iterations = iterations + 1
      
      end do

      deallocate(stack)
      visited_suma = sum(merge(1, 0, visited)) 
      end subroutine topple

c---------------------------------------------------------------------------
c------------------- Avalanche loop SUBROUTINA -------------------------------
c --------------------------------------------------------------------------
      subroutine AvalancheLoop(alpha,critical_value,L,red,visited_suma,
     & iterations,total_energy,heat)
      implicit none
      real*8 critical_value,red,heat,entropyShannon 
      real*8 red_dist,releases,alpha
      real*8 AvalancheSize,total_energy
      integer L,i,j,iterations,capacity,active_zones
      integer n,x,y,visited_suma
      logical active,visited
      integer, allocatable :: stack(:, :)
      dimension red(L,L),releases(L,L),visited(L,L)

      call topple(alpha,critical_value,L,red,iterations,
     & heat,active_zones,visited_suma)

      total_energy=sum(red)
c      print*,visited_suma,iterations,total_energy,heat,
c     & entropyShannon






      end subroutine AvalancheLoop


c---------------------------------------------------------------------------
c------------------- ENTROPY SUBROUTINA -------------------------------------
c --------------------------------------------------------------------------
      subroutine entropy(critical_value,L,red,entropyShannon)
      implicit none
      real*8 entropyShannon,red,critical_value,h
      real*8 min_red, max_red,total_count
      real*8 hist, probabilities
      integer num_bins,bin_index,i,j,L
      parameter (num_bins=100)
      dimension red(L,L)
      dimension hist(num_bins),probabilities(num_bins)
      


      red=red/critical_value
      min_red=minval(red)
      max_red=maxval(red)
      h=(max_red-min_red)/num_bins
      hist=0.d0
      entropyShannon=0.d0
      ! Consttruimos el histograma
      do j=1,L
      do i=1,L
            bin_index=int((red(i,j)-min_red)/h)+1
            if (bin_index > num_bins) then
                  bin_index = num_bins
            end if
            hist(bin_index) = hist(bin_index) + 1.d0
      end do
      end do
        ! Número total de elementos
      total_count = sum(hist)

      ! Normalizamos el histograma a probabilidades
      probabilities = hist/(total_count)
  ! Calculamos la entropía (ignorando probabilidades cero)
      do i = 1, num_bins
      if (probabilities(i) > 0.d0) then
            entropyShannon = entropyShannon - probabilities(i)*log(proba
     &bilities(i))/log(2.d0)
      end if
      end do

      end subroutine entropy


c---------------------------------------------------------------------------
c------------------- RANDOM SUBROUTINA -------------------------------------
c --------------------------------------------------------------------------
      subroutine init_random_seed()
      implicit none
      integer, allocatable :: seed(:)
      integer :: i, n, un, istat, dt(8), pid, t(2), s
      integer(8) :: count, tms

      call random_seed(size = n)
      allocate(seed(n))
! First try if the OS provides a random number generator
      open(newunit=un, file="/dev/urandom", access="stream",
     +  form="unformatted", action="read", status="old", iostat=istat)
      if (istat == 0) then
        read(un) seed
        close(un)
      else
! Fallback to XOR:ing the current time and pid. The PID is
! useful in case one launches multiple instances of the same
! program in parallel.
        call system_clock(count)
        if (count /= 0) then
          t = transfer(count, t)
        else
          call date_and_time(values=dt)
          tms = (dt(1) - 1970) * 365_8 * 24 * 60 * 60 * 1000 
     -         + dt(2) * 31_8 * 24 * 60 * 60 * 1000 
     -         + dt(3) * 24 * 60 * 60 * 60 * 1000 
     -         + dt(5) * 60 * 60 * 1000 
     -         + dt(6) * 60 * 1000 + dt(7) * 1000 
     -         + dt(8)
          t = transfer(tms, t)
        end if
        s = ieor(t(1), t(2))
        pid = getpid() + 1099279 ! Add a prime
        s = ieor(s, pid)
        if (n.ge.3) then
          seed(1) = t(1) + 36269
          seed(2) = t(2) + 72551
          seed(3) = pid
          if (n > 3) then
            seed(4:) = s + 37 * (/ (i, i = 0, n - 4) /)
          end if
        else
          seed = s + 37 * (/ (i, i = 0, n - 1 ) /)
        end if
      end if
      call random_seed(put=seed)
      end subroutine init_random_seed


c---------------------------------------------------------------------------
c------------------- bar SUBROUTINA -------------------------------------
c --------------------------------------------------------------------------
      subroutine print_progress_bar(progress) 
      implicit none
      real*8, intent(in) :: progress
      integer :: i
      integer :: PBWIDTH = 60
      character(len=60) :: PBSTR = 
     &"||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
      character(len=60) :: CTPBSTR
      integer :: val
      integer :: lpad
      integer :: rpad
      
      write(*, *)
      write(*, '(a17)', advance='no') ' Progress : 00.0%'
      
      ! Test the progress bar by incrementing progress
            
      val = int(progress * 100)
      lpad = int(progress * (PBWIDTH + 1))
      rpad = PBWIDTH - lpad
      CTPBSTR = PBSTR(1:lpad)
      CTPBSTR(lpad + 1: PBWIDTH) = ' '
      
      
      write(*,'(a, a, f5.1, a2, a1, a1)', advance="no")
     & char(13), ' progress: ', progress*100, '%'
      write(*, "(A)", advance="no") "["
      write(*, "(A)", advance="no")  CTPBSTR
      write(*, "(A)", advance="no") "]"
      write(*, *) ""
      
      flush(6)

      end subroutine print_progress_bar